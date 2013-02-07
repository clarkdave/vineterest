var config = require('../config'),
    redis = require('./redis'),
    ics = require('iced-coffee-script'),
    Collector = require('./collector')
;

function Jungle() {
  this.collector = new Collector();
}

/**
 * It... gets recent vines. From redis.
 * 
 * @return {[type]} [description]
 */
Jungle.prototype.getRecentVines = function(fn) {

  this.collector.loadVines(function(vines) {

    fn([]);
  });

};


module.exports = Jungle;