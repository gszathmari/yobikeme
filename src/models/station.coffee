geolib = require 'geolib'
citybikes = require 'citybikes-js'
redis = require '../helpers/redis'
geofencedb = require '../helpers/geofencedb'

class Station
  constructor: (@user) ->
    @geofenceDB = geofencedb

  # Transform CityBikes networks into geolib object
  processNetworks: (networks, callback) ->
    results = new Object
    counter = 0
    for network in networks
      results[network.id] =
        latitude: network.geometry.coordinates[1]
        longitude: network.geometry.coordinates[0]
      # Return with callback when iteration is ready
      if ++counter is networks.length
        callback null, results
        return true

  # Transform CityBikes stations into geolib object
  processStations: (stations, callback) ->
    results = new Object
    counter = 0
    error = new Error "error while retrieving stations from CityBikes API"
    # Check if we have any stations at all
    if stations.length is 0
      callback error, null
      return true
    else
      for station in stations
        # Only add stations with available bikes
        if station.properties.free_bikes > 0
          results[station.id] =
            latitude: station.geometry.coordinates[1]
            longitude: station.geometry.coordinates[0]
        # Return with callback when iteration is ready
        if ++counter is stations.length
          # If we have not found any stations with available bikes
          if Object.keys(results).length is 0
            callback error, null
          # Returns cycle hire stations
          else
            callback null, results
          return true

  # Create Google Maps walking directions URL
  constructResponse: (nearestStation) ->
    mapsUrl = "https://www.google.com/maps/dir/"
    mapsUrl += @user.getLocation().latitude
    mapsUrl += ','
    mapsUrl += @user.getLocation().longitude
    mapsUrl += '/'
    mapsUrl += nearestStation.latitude
    mapsUrl += ','
    mapsUrl += nearestStation.longitude
    mapsUrl += '/data=!4m2!4m1!3e2'
    directions =
      url: mapsUrl
      location: [
        parseFloat @user.getLocation().latitude
        parseFloat @user.getLocation().longitude
      ]
      destination: [
        parseFloat nearestStation.latitude
        parseFloat nearestStation.longitude
      ]
    return directions

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
            @processNetworks results, (err, networks) ->
              # Return results with callback
              callback err, networks
              # Cache results in Redis
              unless err
                redis.set [networksName, JSON.stringify networks], (err) ->
                  redis.expire networksName, 60 * 60 unless err
              return true

  findNearestNetwork: (networks) ->
    # Check fenced areas from database file
    for key, area of @geofenceDB
      # If area is geofenced construct response and return the forced network
      if geolib.isPointInside @user.getLocation(), area.points
        fencedNetwork =
          "#{area.name}":
            latitude: networks[area.name].latitude
            longitude: networks[area.name].longitude
        return geolib.findNearest @user.getLocation(), fencedNetwork
    # Return closest network if area is not fenced
    return geolib.findNearest @user.getLocation(), networks

  # Retrieve and cache list of cycle hire stations from CityBikes
  getStations: (nearestNetwork, callback) ->
    networkName = nearestNetwork.key
    # Return error if closest network is further than 25 km
    if nearestNetwork.distance > 25000
      err = new Error "Nearest network is too far"
      callback err, null
      return false
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
            @processStations results, (err, stations) ->
              # Return results with callback
              callback err, stations
              # Cache results in Redis
              unless err
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
          nearestNetwork = @findNearestNetwork(networks)
        catch
          # Return error if geolib throws exception
          err = new Error "error while finding networks"
          callback err, null
          return false
        @getStations nearestNetwork, (err, stations) =>
          if err
            # Return error if getting cycle hire stations has failed
            callback err, null
            return false
          else
            try
              # Find the nearest cycle hire station
              nearestStation = geolib.findNearest @user.getLocation(), stations
            catch
              # Return error if geolib throws exception
              err = new Error "geolib error while finding stations"
              callback err, null
              return false
            # Construct URL and send it back via callback
            callback null, @constructResponse nearestStation
            return true

module.exports = Station
