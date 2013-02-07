var nconf = require('nconf'),
    fs = require('fs')
;

var env = (function() {
  switch (process.env.NODE_ENV) {
    case 'production': return 'production';
    case 'test': return 'test';
    default: return 'development';
  }
})();

var config_file = __dirname + '/' + env + '.json';

if (!fs.existsSync(config_file)) throw "Config file not found!";

nconf.argv().env().file({ file: config_file });

module.exports = nconf;