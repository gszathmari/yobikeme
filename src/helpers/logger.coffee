winston = require 'winston'

options =
  transports: [new winston.transports.Console]

logger = new winston.Logger options

module.exports = logger
