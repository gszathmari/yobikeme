restify = require 'restify'
git = require 'git-rev'

User = require '../models/user'
Station = require '../models/station'
logger = require '../helpers/logger'
yoclient = require '../helpers/yoclient'
eventLogger = require '../helpers/eventlogger'

helpUrl = process.env.YOBIKEME_HELP or "http://bit.ly/yobikeme-help"
errorUrl = process.env.YOBIKEME_ERROR or "http://bit.ly/yobikeme-help"
success =
  success: true

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
  user = new User req.params
  user.isValid (err, user) ->
    # Validation error
    if err
      res.send new restify.BadRequestError err.message
      return next(false)
    else
      #
      # Single-taps: Yo back the URL with the instructions
      #
      unless user.getLocation()
        # Yo back Help URL
        yoclient.send user.getId(), helpUrl, (err, response) ->
          # Sending Yo has failed, log errors and close connection
          if err
            # Fire 'errors' event to log error
            eventLogger.fireErrors user, err
            # Log error if sending Yo has failed
            message = "Error while submitting Yo help
              to #{user.getId()} (Coordinates: #{user.getLocation()})"
            logger.error "#{message}: #{err.name}: #{err.message}"
            # Send error message back to the API client
            res.send new restify.BadRequestError message
            return next(false)
          # Sending Yo has succeeded
          else
            # Fire 'instructions' event
            eventLogger.fireInstructions user, helpUrl
            # Great success!
            logger.info "SUCCESS: Yo help sent to #{user.getId()}"
            # Send API response back and close connection
            res.json success
            return next()
      #
      # Double-taps: retrieve nearest cycle hire station and Yo it back
      #
      else
        station = new Station user
        # Retrieve nearest cycle hire station
        station.locate (err, directions) ->
          # Finding nearest station has failed. Log error and send reponses back
          if err
            # Fire 'errors' event to log error
            eventLogger.fireErrors user, err
            # Send Yo with URL to error page if CityBikes lookup has failed
            yoclient.send user.getId(), errorUrl, (err) ->
              # Log if Yo fails
              if err
                # Fire 'errors' event to log Yo error
                eventLogger.fireErrors user, err
                # Construct error message and log it
                message = "Error while submitting Yo error URL
                 to #{user.getId()} (Coordinates: #{user.getLocation()})"
                logger.error "#{message}: #{err.name}: #{err.message}"
            # Send 404 if CityBikes lookup has failed
            message = "Error while retrieving the nearest station for user
             #{user.getId()}"
            logger.warn "#{message}: #{err.name}: #{err.message}"
            # Send error message back to the API client
            res.send new restify.NotFoundError message
            return next(false)
          # Retrieval of nearest station has succeeded
          else
            # Yo back the Google Maps directions
            yoclient.send user.getId(), directions.url, (err, response) ->
              # Sending Yo has failed, go and log errors
              if err
                # Fire 'errors' event to log Yo error
                eventLogger.fireErrors user, err
                # Construct error message and log it
                message = "Error while submitting Yo directions
                 to #{user.getId()} (Coordinates: #{user.getLocation()})"
                logger.error "#{message}: #{err.name}: #{err.message}"
                # Send error message back to the API client
                res.send new restify.BadRequestError message
                return next(false)
              # Sending Yo has succeeded
              else
                # Great success!
                logger.info "SUCCESS: Yo directions sent to #{user.getId()}"
                # Fire 'directions' event
                eventLogger.fireDirections user, directions
                # Send API response back and close connection
                res.json success
                return next()
