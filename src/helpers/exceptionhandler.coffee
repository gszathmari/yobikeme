#
# Catches all unhandled exceptions
#
logger = require './logger'

exceptionHandler = (req, res, route, err) ->
  # Log exception
  logger.error "#{err.name}: #{err.message}"
  logger.debug err.stack
  response =
    message: "InternalServerError"
    description: "Ouch! Internal server error, please try again"
  res.json 500, response
  throw new Error "Uncaught Exception"

module.exports = exceptionHandler
