config = require('../config')
logger = require('./logger')
redis = require('./redis')
_ = require('underscore')

class Collector

  searchUrl: 'http://search.twitter.com/search.json'
  vineHost: 'vine.co'
  request: require('request')

  constructor: ->

  ##
  # Takes up to two arguments:
  # - search_string, fn - only load vines matching this search string
  # - fn - just load any vine
  ##
  loadVines: (args...) ->

    fn = args.pop()

    await
      if _(args).isEmpty()
        search = ''
        @getVineTweets defer tweets
      else
        search = args.pop()
        @getVineTweets search, defer tweets

    vines = []
    @cache_hits = 0

    # process vines in parallel (or this will take aaaaaages)
    logger.info 'Downloading Vine video/image information...'
    await
      for tweet, i in tweets
        @processTweet tweet, defer vines[i]

    vines = vines.filter (v) -> v?

    if @cache_hits
      logger.info(@cache_hits + ' vine cache hits')

    # we have vines?
    if _(vines).isEmpty()
      return fn()

    # store these vines in redis
    
    pairs = _.flatten( ['vines_' + search, vines.map( (v) -> [v.id, JSON.stringify(v)] ) ] )
    redis.zadd pairs, (err, reply) ->
      logger.info 'Added ' + reply + ' vines to vines_' + search + ' sorted set'
      fn(vines)


  ##
  # Takes up to two args:
  # - search_string, fn
  # - fn
  ##
  getVineTweets: (args...) ->

    fn = args.pop()

    if _(args).isEmpty()
      search = 'vine.co'
    else
      search = args.pop() + ' vine.co'

    url = @searchUrl +
    '?q=' + encodeURIComponent(search) +
    '&include_entities=true' +
    '&rpp=50'

    logger.info 'Searching twitter ' + url
    await @request.get url: url, json: true, defer err, response, body

    # tidy up these tweets a bit
    tweets = body.results.map (t) ->
      
      id: t.id
      text: t.text
      user:
        name: t.from_user
        image: t.profile_image_url
      url: t.entities.urls.filter( (u) -> u.expanded_url.match /vine.co/ ).map( (u) -> u.expanded_url )[0]


    # TODO: stash in redis the metadata about this request, so we know
    # what search params to use next time

    fn(tweets)


  processTweet: (tweet, fn) ->

    

    vine_url = tweet.url
    unless vine_url?
      return fn(null)

    vine_url_key = vine_url.replace /https?:\/\//, '' 

    # we cache even if the vine is null, because that way we know it's a dud and won't
    # check it again in future
    cache = (data) ->
      redis.hset "all_vines", vine_url_key, JSON.stringify(data)

    vine =
      id: tweet.id
      url: vine_url

    delete tweet.id
    delete tweet.url

    vine.tweet = tweet

    # check if we have the video/image info cached for this vine
    await redis.hget "all_vines", vine_url_key, defer err, data
    if data?
      data = JSON.parse(data)
      if data?
        @cache_hits++
        _.extend vine, data
        return fn(vine)
      else
        # we've checked this before, and it was broken, so ignore now
        return fn(null)

    # fetch the vine page, and regex out what we need
    await @request.get vine_url, defer err, response, body

    m = body.match /property="twitter:image"\s+content="([^"]+)"/
    vine.image = m[1] if m?

    m = body.match /property="twitter:player:stream"\s+content="([^"]+)"/
    vine.video = m[1] if m?

    unless vine.image and vine.video
      logger.error 'Could not get Vine image or video for ' + vine_url + '', vine
      cache(null)
      return fn(null)
    
    cache video: vine.video, image: vine.image
    fn(vine)


module.exports = Collector