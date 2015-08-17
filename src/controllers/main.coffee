restify = require 'restify'

Station = require '../models/station'
logger = require '../helpers/logger'
yoclient = require '../helpers/yoclient'

exports.index = (req, res, next) ->
  res.send "OK"
  return next()

exports.yo = (req, res, next) ->
  helpUrl = process.env.YOBIKEME_HELP or "http://bit.ly/yobikeme-help"
  success =
    success: true
  # Single-taps: Yo back the URL with the instructions
  unless req.params.location
    # Yo back Help URL
    yoclient.send req.params.username, helpUrl, (err, response) ->
      if err
        # Send error back if sending Yo has failed
        message = "Error while submitting Yo help to #{req.params.username}"
        logger.error "#{message}: #{err.message}"
        res.send new restify.BadRequestError message
        return next(false)
      else
        # Great success!
        logger.info "SUCCESS: Yo help sent to #{req.params.username}"
        res.json success
        return next()
  # Double-taps: retrieve nearest cycle hire station and Yo it back
  else
    station = new Station req.params.location
    # Retrieve nearest cycle hire station
    station.locate (err, mapsUrl) ->
      if err
        # Send 404 if CityBikes lookup has failed
        message = "Error while retrieving the nearest station for user
         #{req.params.username}"
        logger.warn "#{message}: #{err.message}"
        res.send new restify.NotFoundError message
        return next(false)
      else
        # Yo back the Google Maps directions
        yoclient.send req.params.username, mapsUrl, (err, response) ->
          if err
            # Send error back if sending Yo has failed
            message = "Error while submitting Yo directions
             to #{req.params.username}"
            logger.error "#{message}: #{err.message}"
            res.send new restify.BadRequestError message
            return next(false)
          else
            # Great success!
            logger.info "SUCCESS: Yo directions sent to #{req.params.username}"
            res.json success
            return next()
