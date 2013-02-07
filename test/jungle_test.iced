Jungle = require('../lib/jungle')
redis = require('../lib/redis')

describe 'Jungle', ->

  before ->
    redis.flushall()

  describe 'getRecentVines', ->

    jungle = null

    before ->
      jungle = new Jungle()

    it 'should get recent vines', (done) ->

      await jungle.getRecentVines defer vines
      vines.should.eql []

      done()