restify = require 'restify'
git = require 'git-rev'

Station = require '../models/station'
logger = require '../helpers/logger'
yoclient = require '../helpers/yoclient'
eventLogger = require '../helpers/eventlogger'

# Serve simple message on index
exports.index = (req, res, next) ->
  res.send "OK"
  return next()

# Serve commit hash
exports.hash = (req, res, next) ->
  git.long (hash) ->
    m =
      hash: hash
    res.json m
    return next()

exports.yo = (req, res, next) ->
  # Return error if username was not supplied for any reason
  unless req.params.username
    res.send new restify.BadRequestError "Please submit a username"
    return next(false)
  helpUrl = process.env.YOBIKEME_HELP or "http://bit.ly/yobikeme-help"
  success =
    success: true
  # Single-taps: Yo back the URL with the instructions
  unless req.params.location
    # Yo back Help URL
    yoclient.send req.params.username, helpUrl, (err, response) ->
      if err
        # Fire 'errors' event to log error
        eventLogger.fireErrors req, err
        # Send error back if sending Yo has failed
        message = "Error while submitting Yo help to #{req.params.username}"
        logger.error "#{message}: #{err.name}: #{err.message}"
        res.send new restify.BadRequestError message
        return next(false)
      else
        # Fire 'instructions' event
        eventLogger.fireInstructions req, helpUrl
        # Great success!
        logger.info "SUCCESS: Yo help sent to #{req.params.username}"
        # Send API response back and close connection
        res.json success
        return next()
  # Double-taps: retrieve nearest cycle hire station and Yo it back
  else
    station = new Station req.params.location
    # Retrieve nearest cycle hire station
    station.locate (err, directions) ->
      if err
        # Fire 'errors' event to log error
        eventLogger.fireErrors req, err
        # Send 404 if CityBikes lookup has failed
        message = "Error while retrieving the nearest station for user
         #{req.params.username}"
        logger.warn "#{message}: #{err.name}: #{err.message}"
        res.send new restify.NotFoundError message
        return next(false)
      else
        # Yo back the Google Maps directions
        yoclient.send req.params.username, directions.url, (err, response) ->
          if err
            # Fire 'errors' event to log error
            eventLogger.fireErrors req, err
            # Send error back if sending Yo has failed
            message = "Error while submitting Yo directions
             to #{req.params.username}"
            logger.error "#{message}: #{err.name}: #{err.message}"
            res.send new restify.BadRequestError message
            return next(false)
          else
            # Great success!
            logger.info "SUCCESS: Yo directions sent to #{req.params.username}"
            # Fire 'directions' event
            eventLogger.fireDirections req, directions
            # Send API response back and close connection
            res.json success
            return next()
