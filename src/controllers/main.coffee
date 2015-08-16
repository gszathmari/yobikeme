Station = require '../models/station'
request = require 'request'
logger = require '../helpers/logger'
restify = require 'restify'

exports.index = (req, res, next) ->
  res.send "OK"
  return next()

exports.yo = (req, res, next) ->
  # Push Yo through the Yo API
  pushYo = (options) ->
    request.post options, (error, response, body) ->
      # If Yo API reports an error, log and fail
      if error
        message = "Error while sending Yo to #{req.params.username}"
        logger.warn "#{message}: #{error}"
        res.send new restify.BadRequestError message
        return next(false)
      # Great success!
      else
        logger.info "SUCCESS: Yo has been sent to #{req.params.username}"
        res.status response.statusCode
        res.json JSON.parse body
        return next()

  # If Yo API does not send us the location parameters, Yo back a help URL
  unless req.params.location
    options =
      url: "https://api.justyo.co/yo/"
      qs:
        api_token: process.env.YO_API_TOKEN
        username: req.params.username
        link: process.env.YOBIKEME_HELP or "http://bit.ly/yobikeme-help"
    # Send back the YOBIKEME help
    pushYo options
  # Retrieve nearest cycle hire station and Yo it back
  else
    station = new Station req.params.location
    # Retrieve nearest cycle hire station
    station.locate (err, mapsUrl) ->
      if err
        message = "Error while retrieving nearest station"
        logger.warn "#{message}: #{err.message}"
        res.send new restify.NotFoundError message
        return next(false)
      else
        # Construct request object for the Yo API
        options =
          url: "https://api.justyo.co/yo/"
          qs:
            api_token: process.env.YO_API_TOKEN
            username: req.params.username
            link: mapsUrl
        # Send results back
        pushYo options
