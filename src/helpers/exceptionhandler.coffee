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
  # Throwing back the exception to force the application exit
  throw err

module.exports = exceptionHandler
