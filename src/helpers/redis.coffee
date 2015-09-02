redis = require 'redis'
cfenv = require 'cfenv'

logger = require './logger'

appEnv = cfenv.getAppEnv()
re = new RegExp /.*edis.*/i
host =
  process.env.REDIS_DB_HOST or
  appEnv.getServiceCreds(re)?.hostname or
  "127.0.0.1"
port =
  process.env.REDIS_DB_PORT or
  appEnv.getServiceCreds(re)?.port or
  "6379"
password = process.env.REDIS_DB_PASSWORD or appEnv.getServiceCreds(re)?.password
options =
  retry_max_delay: 5 * 1000

# Check if we run in Docker
if process.env.REDIS_PORT_6379_TCP_ADDR and process.env.REDIS_PORT_6379_TCP_PORT
  host = "redis"
  port = "6379"

client = redis.createClient(port, host, options)

client.auth password if password

client.on "error", (err) ->
  logger.warn err.message

module.exports = client
