Station = require '../models/station'
request = require 'request'
logger = require '../helpers/logger'

exports.index = (req, res, next) ->
  res.send "OK"
  return next()

exports.yo = (req, res, next) ->
  station = new Station req.params.location
  # Retrieve nearest cycle hire station
  station.locate (err, mapsUrl) ->
    # Construct request object for the Yo API
    options =
      qs:
        api_token: process.env.YO_API_TOKEN
        link: mapsUrl
        username: req.params.username
      url: "https://api.justyo.co/yo/"
    # Push Yo through the Yo API
    request.post options, (error, response, body) ->
      if error
        logger.warn "Error while sending Yo to #{req.params.username}: #{error}"
        res.status 500
        res.end()
      else
        logger.info "Yo has been sent to #{req.params.username}"
        res.status response.statusCode
        res.json JSON.parse body
      return next()
