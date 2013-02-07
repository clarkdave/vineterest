Collector = require('../lib/collector')
redis = require('../lib/redis')
sinon = require('sinon')
should = require('should')
fs = require('fs')

describe 'Collector', ->

  before ->
    redis.flushall()

  describe 'getVineTweets', ->

    collector = null

    before ->
      collector = new Collector()

    it 'should get vine tweets', (done) ->
      # make restler return some tweets
      
      stub = sinon.stub collector.request, 'get', (opts, fn) ->
        fn null, {}, require('./fixtures/twitter_vine_search')

      await collector.getVineTweets defer tweets
      tweets.length.should.eql 4
      tweets[0].should.eql {
        id: 1024
        text: 'Lorem ipsum'
        user:
          name: 'clarkdave'
          image: 'http://example.com/a'
      }

      stub.restore()
      done()

  describe 'processTweet', ->

    collector = null

    before ->
      collector = new Collector()

    it 'should ignore non-vine tweets', (done) ->
      stub = sinon.stub collector.request, 'head', (url, fn) ->
        fn null, request: { uri: { host: 'tumblr.com' } }

      await collector.processTweet {
        id: 1024
        text: 'Lorem ipsum #vine http://t.co/ayxiwk0'
        user:
          name: 'clarkdave'
          image: 'http://example.com/a'
      }, defer vine

      should.not.exist vine

      stub.restore()
      done()


    it 'should process vine tweets', (done) ->
      sinon.stub collector.request, 'head', (url, fn) ->
        fn null, request: { uri: { host: 'vine.co' } }

      sinon.stub collector.request, 'get', (url, fn) ->
        html = fs.readFileSync(__dirname + '/fixtures/vine_page.html', 'utf8')
        fn null, {}, html

      await collector.processTweet {
        id: 1024
        text: 'Lorem ipsum #vine http://t.co/ayxiwk0'
        user:
          name: 'clarkdave'
          image: 'http://example.com/a'
      }, defer vine

      should.exist vine

      done()
