config = require('../config')
redis = require('./redis')
ics = require('iced-coffee-script')
Collector = require('./collector')


class Jungle



  ##
  # Get recent vines... from redis
  ##
  getRecentVines: (fn) ->
    redis.zrevrange 'vines_', 0, 50, (err, vines) ->
      fn vines.map (v) -> JSON.parse(v)

module.exports = Jungle