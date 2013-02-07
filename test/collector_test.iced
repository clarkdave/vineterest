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

    it 'should get vine tweets without search string', (done) ->
      # make request return some tweets
      request = sinon.stub collector.request, 'get', (opts, fn) ->
        fn null, {}, require('./fixtures/twitter_vine_search')

      await collector.getVineTweets defer tweets
      request.firstCall.args[0].url.should.match /q=%23vine/
      tweets.length.should.eql 4
      tweets[0].should.eql {
        id: 1024
        text: 'Lorem ipsum'
        user:
          name: 'clarkdave'
          image: 'http://example.com/a'
      }

      request.restore()
      done()

    it 'should get vine tweets with a search string', (done) ->
      request = sinon.stub collector.request, 'get', (opts, fn) ->
        fn null, {}, require('./fixtures/twitter_vine_search')

      await collector.getVineTweets 'cat', defer tweets
      request.firstCall.args[0].url.should.match /q=cat%20%23vine/
      tweets.length.should.eql 4

      request.restore()
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
      vine.should.eql {
        tweet:
          id: 1024
          text: 'Lorem ipsum #vine http://t.co/ayxiwk0'
          user:
            name: 'clarkdave'
            image: 'http://example.com/a'
        image: 'https://vines.s3.amazonaws.com/thumbs/CA5345A2-88F2-4434-829B-7651027064A2-2160-000001F544A71EAB_1.0.5.mp4.jpg?versionId=OXVqPOozqG9cxKLt455bwj0B0gay7pfK'
        video: 'https://vines.s3.amazonaws.com/videos/CA5345A2-88F2-4434-829B-7651027064A2-2160-000001F544A71EAB_1.0.5.mp4?versionId=._SuVJ_bn4xpvzKJbYllJ44g8Huxe0ID'
      }



      done()
