Keen = require 'keen-js'

logger = require './logger'

class EventLogger
  constructor: ->
    options =
      projectId: process.env.KEEN_PROJECT_ID
      writeKey: process.env.KEEN_WRITE_API_KEY
      protocol: "https"
    configured = options.projectId and options.writeKey
    @client = new Keen options if configured

  # Send event to Keen.io
  sendEvent: (eventName, eventData) ->
    # Check if environmental variables are configured or fail silently
    if @client
      @client.addEvent eventName, eventData, (err, res) ->
        if err
          m = "Error while sending #{eventName} event to Keen.io: #{err}"
          logger.error m

  # Construct 'directions' event
  fireDirections: (req, directions) ->
    directionsEvent =
      user:
        id: req.params.username
        ip_address: req.params.user_ip or "127.0.0.1"
      destination:
        coordinates: [directions.destination[1], directions.destination[0]]
      yo_url: directions.url
      keen:
        location:
          coordinates: [directions.location[1], directions.location[0]]
        addons: [
          {
            name: "keen:url_parser"
            input:
               url: "yo_url"
            output: "parsed_yo_url"
          },
          {
            name: "keen:ip_to_geo"
            input:
              ip: "user.ip_address"
            output: "ip_geo_info"
          }
        ]
    @sendEvent "directions", directionsEvent

  # Construct 'instructions' event
  fireInstructions: (req, url) ->
    instructionsEvent =
      user:
        id: req.params.username
        ip_address: req.params.user_ip or "127.0.0.1"
      yo_url: url
      keen:
        addons: [
          {
            name: "keen:url_parser"
            input:
               url: "yo_url"
            output: "parsed_yo_url"
          },
          {
            name: "keen:ip_to_geo"
            input:
              ip: "user.ip_address"
            output: "ip_geo_info"
          }
        ]
    @sendEvent "instructions", instructionsEvent

module.exports = new EventLogger
