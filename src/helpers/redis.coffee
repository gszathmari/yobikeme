redis = require 'redis'

logger = require './logger'

host = process.env.REDIS_HOST or "127.0.0.1"
port = process.env.REDIS_PORT or "6379"
options =
  retry_max_delay: 5 * 1000

client = redis.createClient(port, host, options)

client.auth process.env.REDIS_PASSWORD

client.on "error", (err) ->
  logger.warn err.message

module.exports = client
