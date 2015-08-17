#
# Main API Server
#

restify = require 'restify'
chalk = require 'chalk'

exceptionHandler = require './helpers/exceptionhandler'
logger = require './helpers/logger'

app = module.exports = restify.createServer()
listenHost = process.env.OPENSHIFT_NODEJS_IP or "0.0.0.0"
listenPort = process.env.OPENSHIFT_NODEJS_PORT or 8080

#
# Applying Restify built-in plugins and other helpers
#

# Restify workaround for cURL
app.pre restify.pre.userAgentConnection()
# Restify workaround for handling trailing slashes
app.pre restify.pre.sanitizePath()
app.use restify.queryParser()

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