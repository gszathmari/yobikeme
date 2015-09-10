#
# Main API Server
#
# Newrelic should be on the top
newrelic = require './helpers/newrelic'
rollbar = require './helpers/rollbar'

restify = require 'restify'
chalk = require 'chalk'
morgan = require 'morgan'

exceptionHandler = require './helpers/exceptionhandler'
logger = require './helpers/logger'

app = module.exports = restify.createServer()
listenHost = process.env.HOST or process.env.VCAP_APP_HOST or "0.0.0.0"
listenPort = process.env.PORT or process.env.VCAP_APP_PORT or 8080

#
# Applying Restify built-in plugins and other helpers
#

# Restify workaround for cURL
app.pre restify.pre.userAgentConnection()
# Restify workaround for handling trailing slashes
app.pre restify.pre.sanitizePath()
app.use restify.queryParser()
# Dump HTTP logs to console
app.use morgan 'tiny'

# Prevents leaking internal errors through the API
app.on 'uncaughtException', exceptionHandler

#
# Launching server
#

server = app.listen listenPort, listenHost, ->
  address = server.address().address
  port = server.address().port
  logger.info \
    chalk.green "Server listening on http://#{address}:#{port} " +
    chalk.grey "(PID: #{process.pid})"

module.exports.app = app
routes = require './routes'
