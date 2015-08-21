geolib = require 'geolib'
citybikes = require 'citybikes-js'
redis = require '../helpers/redis'
logger = require '../helpers/logger'

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

  # Retrieve and cache list of cycle hire networks from CityBikes
  getNetworks: (callback) ->
    networksName = "networks"
    # Retrieve cycle hire networks from cache
    redis.get networksName, (err, networks) =>
      if networks
        callback null, JSON.parse networks
        return true
      else
        # Retrieve from CityBikes if data was not cached
        citybikes.networks (err, results) =>
          if err
            callback err, null
            return false
          else
            # Transform CityBikes format to geolib format
            networks = @processItems results
            # Return results with callback
            callback null, networks
            # Cache results in Redis
            redis.set [networksName, JSON.stringify networks], (err) ->
              redis.expire networksName, 60 * 60 unless err
            return true

  # Retrieve and cache list of cycle hire stations from CityBikes
  getStations: (networkName, callback) ->
    # Retrieve list of stations from cache
    redis.get networkName, (err, stations) =>
      if stations
        callback null, JSON.parse stations
        return true
      # Retrieve from CityBikes if data was not cached
      else
        citybikes.stations networkName, (err, results) =>
          if err
            callback err, null
            return false
          else
            # Transform CityBikes format to geolib format
            stations = @processItems results
            # Return results with callback
            callback null, stations
            # Cache results in Redis
            redis.set [networkName, JSON.stringify stations], (err) ->
              redis.expire networkName, 60 * 3 unless err
            return true

  # Locate the nearest cycle hire station
  locate: (callback) ->
    @getNetworks (err, networks) =>
      if err
        # Return error if getting cycle hire networks has failed
        callback err, null
        return false
      else
        try
          # Find the nearest cycle hire service
          nearestNetwork = geolib.findNearest @coordinates, networks
        catch
          # Return error if geolib throws exception
          err = new Error "geolib error while finding networks"
          callback err, null
          return false
        @getStations nearestNetwork.key, (err, stations) =>
          if err
            # Return error if getting cycle hire stations has failed
            callback err, null
            return false
          else
            try
              # Find the nearest cycle hire station
              nearestStation = geolib.findNearest @coordinates, stations
            catch
              # Return error if geolib throws exception
              err = new Error "geolib error while finding stations"
              callback err, null
              return false
            # Construct URL and send it back via callback
            callback null, @constructUrl nearestStation
            return true

module.exports = Station
