var kue = require('kue'),
    config = require('./config'),
    logger = require('./lib/logger'),
    redis = require('redis'),
    ics = require('iced-coffee-script'),
    Collector = require('./lib/collector')
;

kue.redis.createClient = function() {
  var client = redis.createClient(config.get('redis:port'), config.get('redis:host'));
  return client;
};


var jobs = kue.createQueue(),
    collector = new Collector()
;

var get_vines = function() {
  var job = jobs.create('get_vines', {
    search: ''
  }).priority('high').save();

  job.on('complete', function() {
    
  });
};

get_vines();

/**
 * Get new vines every 30s
 */
setInterval(function() {
  get_vines();
}, 30000);

// start promotion scheduler
jobs.promote();

jobs.process('get_vines', function(job, done) {

  var search = job.data.search || '';

  collector.loadVines(search, function(vines) {
    done();
  });
});



kue.app.listen(3001);
logger.info('Kue UI started on port 3001');