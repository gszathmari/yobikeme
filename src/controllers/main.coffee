Station = require '../models/station'
request = require 'request'
logger = require '../helpers/logger'
restify = require 'restify'

exports.index = (req, res, next) ->
  res.send "OK"
  return next()

exports.yo = (req, res, next) ->
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
      # Push Yo through the Yo API
      request.post options, (error, response, body) ->
        if error
          message = "Error while sending Yo to #{req.params.username}"
          logger.warn "#{message}: #{error}"
          res.send new restify.BadGatewayError message
          return next(false)
        else
          logger.info "Yo has been sent to #{req.params.username}"
          res.status response.statusCode
          res.json JSON.parse body
          return next()
