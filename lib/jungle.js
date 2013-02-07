var config = require('../config'),
    redis = require('redis').createClient( config.get('redis:port'), config.get('redis:host') )
;

function Jungle() {
  
}

/**
 * It... gets recent vines. From redis.
 * 
 * @return {[type]} [description]
 */
Jungle.prototype.getRecentVines = function(fn) {

  redis.keys('*', function(err, r) {
    console.log(r);
  });

};


module.exports = Jungle;