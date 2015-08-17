yoapi = require 'yo-api2'

unless process.env.YO_API_TOKEN
  throw new Error "YO_API_TOKEN environmental variable is missing"

class YoClient
  constructor: ->
    @yo = yoapi process.env.YO_API_TOKEN

  send: (username, url, callback) ->
    @yo username, url, callback

module.exports = new YoClient
