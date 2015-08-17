redis = require 'redis'
cfenv = require 'cfenv'

logger = require './logger'

appEnv = cfenv.getAppEnv()
re = new RegExp /.*edis.*/i
host =
  process.env.REDIS_HOST or
  appEnv.getServiceCreds(re)?.hostname or
  "127.0.0.1"
port =
  process.env.REDIS_PORT or
  appEnv.getServiceCreds(re)?.port or
  "6379"
options =
  retry_max_delay: 5 * 1000

client = redis.createClient(port, host, options)

client.auth process.env.REDIS_PASSWORD or appEnv.getServiceCreds(re)?.password

client.on "error", (err) ->
  logger.warn err.message

module.exports = client
