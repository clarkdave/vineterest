config = require('../config')
redis = require('redis')
_ = require('underscore')

class Collector

  searchUrl: 'http://search.twitter.com/search.json'
  vineHost: 'vine.co'
  request: require('request')

  constructor: ->

  ##
  # Takes up to two args:
  # - search_string, fn
  # - fn
  ##
  getVineTweets: (args...) ->

    fn = args.pop()

    if _(args).isEmpty()
      search = '#vine'
    else
      search = args.pop() + ' #vine'

    url = @searchUrl +
    '?q=' + encodeURIComponent(search) +
    '&include_entities=true' +
    '&rpp=50'

    await @request.get url: url, json: true, defer err, response, body

    # tidy up these tweets a bit
    tweets = body.results.map (t) ->
      id: t.id
      text: t.text
      user:
        name: t.from_user
        image: t.profile_image_url


    # TODO: stash in redis the metadata about this request, so we know
    # what search params to use next time

    fn(tweets)


  processTweet: (tweet, fn) ->
    
    m = tweet.text.match /t\.co\/[a-z0-9]+/
    return fn(null) unless m?
    url = m[0]
    
    # not all #vine tweets actually contain a url to a vine, so to avoid
    # requesting stupid amounts of html we'll check first...
    await @request.head 'http://' + url, defer err, response

    return fn(null) unless response.request.uri.host is @vineHost

    # now fetch the vine page, and regex out what we need
    await @request.get 'http://' + url, defer err, response, body
    
    vine =
      tweet: tweet

    m = body.match /property="twitter:image"\s+content="([^"]+)"/
    vine.image = m[1] if m?

    m = body.match /property="twitter:player:stream"\s+content="([^"]+)"/
    vine.video = m[1] if m?

    unless vine.image and vine.video
      console.error 'Could not get Vine image or video for <http://' + url + '>'
      fn()
    else
      fn(vine)


module.exports = Collector