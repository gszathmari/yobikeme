geolib = require 'geolib'
citybikes = require 'citybikes-js'

class Station
  constructor: (@location) ->
    data = @location.split ';'
    @coordinates =
      latitude: data[0]
      longitude: data[1]

  # Transform CityBikes response into geolib object
  processItems: (items) ->
    result = new Object
    for item in items
      result[item.id] =
        latitude: item.geometry.coordinates[1]
        longitude: item.geometry.coordinates[0]
    return result

  # Create Google Maps walking directions URL
  constructUrl: (nearestStation) ->
    url = "https://www.google.com/maps/dir/"
    url += @coordinates.latitude
    url += ','
    url += @coordinates.longitude
    url += '/'
    url += nearestStation.latitude
    url += ','
    url += nearestStation.longitude
    url += '/data=!4m2!4m1!3e2'
    return url

  locate: (callback) ->
    # Get cycle hire networks
    citybikes.networks (err, networks) =>
      if err then callback err, null
      # Find nearest cycle hire network
      nearestNetwork = geolib.findNearest @coordinates, @processItems networks
      # Get stations of cycle hire service
      citybikes.stations nearestNetwork.key, (err, stations) =>
        if err then callback err, null
        # Find nearest cycle hire station
        nearestStation = geolib.findNearest @coordinates, @processItems stations
        # Create Google Maps URL
        mapsUrl = @constructUrl nearestStation
        # Return URL with callback
        callback null, mapsUrl

module.exports = Station
