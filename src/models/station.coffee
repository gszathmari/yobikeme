{EventEmitter}  = require 'events'
geolib = require 'geolib'
citybikes = require 'citybikes-js'
redis = require '../helpers/redis'

class Station
  constructor: (@location) ->
    @events = new EventEmitter
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
    @events.on "networksRetrieved", (networks) =>
      # Find the nearest cycle hire service
      nearestNetwork = geolib.findNearest @coordinates, networks
      # Retrieve list of stations from cache
      redis.get nearestNetwork.key, (err, stations) =>
        if stations
          @events.emit "stationsRetrieved", JSON.parse stations
        # Retrieve from CityBikes if data is not cached
        else
          citybikes.stations nearestNetwork.key, (err, results) =>
            # Transform CityBikes format to geolib format
            stations = @processItems results
            redis.set nearestNetwork.key, JSON.stringify stations
            redis.expire nearestNetwork.key, 60 * 5
            @events.emit "stationsRetrieved", stations

    # Find nearest cycle hire station
    @events.on "stationsRetrieved", (stations) =>
      nearestStation = geolib.findNearest @coordinates, stations
      # Construct Google Maps URL
      mapsUrl = @constructUrl nearestStation
      # Send result back via callback
      callback null, mapsUrl

    # Retrieve cycle hire networks from cache
    redis.get "networks", (err, networks) =>
      if networks
        @events.emit "networksRetrieved", JSON.parse networks
      else
        # Retrieve from CityBikes if data is not cached
        citybikes.networks (err, results) =>
          # Transform CityBikes format to geolib format
          networks = @processItems results
          redis.set "networks", JSON.stringify networks
          redis.expire "networks", 60 * 30
          @events.emit "networksRetrieved", networks

module.exports = Station
