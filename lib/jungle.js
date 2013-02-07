var config = require('../config'),
    redis = require('./redis')
;

function Jungle() {
  
}

/**
 * It... gets recent vines. From redis.
 * 
 * @return {[type]} [description]
 */
Jungle.prototype.getRecentVines = function(fn) {

  fn([]);
  // redis.keys('*', function(err, r) {
  //   console.log(r);
  //   fn([]);
  // });

};


module.exports = Jungle;