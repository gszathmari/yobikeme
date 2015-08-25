validator = require 'validator'

class User
  constructor: (data) ->
    @error = null
    @data = @sanitize data

  sanitize: (data) ->
    data = data or {}
    @error = @validate data
    return data

  validate: (data) ->
    # Validate 'username' parameter
    unless validator.isLength data.username, 1, 32
      return new TypeError "Username format is invalid"
    # Validate 'user_ip=' parameter
    if data.user_ip
      unless validator.isIP data.user_ip, 4
        return new TypeError "Invalid IP address format"
    # Validate 'location=' parameter
    if data.location
      coordinates = data.location.split ';'
      boundaries =
        min: -180
        max: 180
      unless validator.contains data.location, ';'
        return new TypeError "Invalid location parameter"
      unless validator.isFloat coordinates[0], boundaries
        return new RangeError "Invalid location coordinate"
      unless validator.isFloat coordinates[1], boundaries
        return new RangeError "Invalid location coordinate"
    # Return 'null' if validations have passed
    return null

  # Return username
  getId: ->
    return @data.username

  # Return IP address
  getIP: (callback) ->
    return @data.user_ip or "127.0.0.1"

  # Return latitude / longitude as array
  getLocation: (callback) ->
    coordinates = null
    try
      location = @data.location.split ';'
      coordinates =
        latitude: location[0]
        longitude: location[1]
    return coordinates

  # Return validation error
  isValid: (callback) ->
    callback @error, @
    return @error

  # Getter
  get: (name) ->
    return @data[name]

  # Setter
  set: (name, value) ->
    @data[name] = value

module.exports = User
