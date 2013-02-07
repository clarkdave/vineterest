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

    # process vines in parallel (or this will take aaaaaages)
    logger.info 'Downloading Vine video/image information...'
    await
      for tweet, i in tweets
        @processTweet tweet, defer vines[i]

    vines = vines.filter (v) -> v?

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
    return fn(null) unless vine_url?
    
    # not all #vine tweets actually contain a url to a vine, so to avoid
    # requesting stupid amounts of html we'll check first...
    # await @request.head url: 'http://' + url, followAllRedirects: true, defer err, response
    
    # return fn(null) unless response.request.uri.host is @vineHost

    # now fetch the vine page, and regex out what we need
    await @request.get vine_url, defer err, response, body
    
    vine =
      id: tweet.id
      url: vine_url

    delete tweet.id
    delete tweet.url

    vine.tweet = tweet

    m = body.match /property="twitter:image"\s+content="([^"]+)"/
    vine.image = m[1] if m?

    m = body.match /property="twitter:player:stream"\s+content="([^"]+)"/
    vine.video = m[1] if m?

    unless vine.image and vine.video
      logger.error 'Could not get Vine image or video for <http://' + url + '>'
      return fn()
    
    fn(vine)


module.exports = Collector