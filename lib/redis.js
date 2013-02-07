var config = require('../config'),
    redis = require('redis')
;

// load and configure a redis client and make it accessible 

var client = redis.createClient( config.get('redis:port'), config.get('redis:host') );

module.exports = client;