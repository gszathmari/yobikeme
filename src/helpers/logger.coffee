winston = require 'winston'
Logentries = require 'winston-logentries'

options =
  transports: [new winston.transports.Console]

if process.env.LOGENTRIES_TOKEN
  le = new winston.transports.Logentries {token: process.env.LOGENTRIES_TOKEN}
  options.transports.push le

logger = new winston.Logger options

module.exports = logger
