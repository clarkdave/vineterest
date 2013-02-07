var winston = require('winston');

var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({ colorize: true })
  ]
});

if (process.env.NODE_ENV === 'test') {
  // shut the logger up during testing
  logger.remove(winston.transports.Console);
}

module.exports = logger;