var nconf = require('nconf');

var env = (function() {
  switch (process.env.NODE_ENV) {
    case 'production': return 'production';
    case 'test': return 'test';
    default: return 'development';
  }
})();

var config_file = path.join('./', this.env + '.json');

if (!fs.existsSync(config_file)) throw "Config file not found!";

nconf.config.argv().env().file({ file: config_file });

module.exports = nconf;