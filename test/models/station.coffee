chai = require 'chai'
sinon = require 'sinon'
validator = require 'validator'
citybikes = require 'citybikes-js'
geolib = require 'geolib'

User = require '../../src/models/user'
Station = require '../../src/models/station'
redis = require '../../src/helpers/redis'

expect = chai.expect

describe 'Model: Station', ->
  req =
    params:
      username: "unittest"
      location: "42.344827;-71.028664"
  user = new User req.params
  latitude = "42.344827"
  longitude = "-71.028664"
  nearestStation =
    latitude: "12.343109"
    longitude: "20.023661"
  item1 =
    id: "abc123"
    geometry:
      coordinates: ["43.344827", "-70.028664"]
    properties:
      free_bikes: 10
  item2 =
    id: "xyz987"
    geometry:
      coordinates: ["12.343109", "20.023661"]
    properties:
      free_bikes: 0
  # Array of cycle hire stations
  items = [item1, item2]
  # Valid network
  nearestNetwork =
    key: "unittest"
    latitude: 46.127196
    longitude: 8.499169
    distance: 10000
  # Network that is too far
  nearestNetwork2 =
    key: "unittest2"
    latitude: -4.3221
    longitude: 2.32912
    distance: 25001
  error = new Error "Unit test error, please ignore"
  networks_redis =
    network1:
      latitude: 0.0
      longitude: 0.0
    network2:
      latitide: 1.0
      longitude: 1.0
  citybikes1 =
    type: 'Feature'
    geometry:
      type: 'Point'
      coordinates: [1.1, 2.2]
    properties:
      company: "unittest1"
      name: 'Unit Test'
      city: 'Unit'
      country: 'Test'
      free_bikes: 51
    id: 'unit-test1'
  citybikes2 =
    type: 'Feature'
    geometry:
      type: 'Point'
      coordinates: [3.3, 4.4]
    properties:
      company: "unittest2"
      name: 'Unit Test'
      city: 'Unit'
      country: 'Test'
      free_bikes: 22
    id: 'unit-test2'
  networks_citybikes = [citybikes1, citybikes2]

  beforeEach ->
    @station = new Station user
    @stub1 = sinon.stub redis, "get"
    @stub2 = sinon.stub citybikes, "networks"
    @stub3 = sinon.stub citybikes, "stations"
    @stub4 = sinon.stub redis, "set"
    @stub5 = sinon.stub redis, "expire"

  it 'constructor should instatinate object', (done) ->
    expect(@station).to.respondTo('processNetworks')
    expect(@station).to.respondTo('processStations')
    expect(@station).to.respondTo('constructResponse')
    expect(@station).to.respondTo('getNetworks')
    expect(@station).to.respondTo('getStations')
    expect(@station).to.respondTo('locate')
    done()

  it 'processNetworks should transform objects', (done) ->
    @station.processNetworks items, (err, networks) ->
      expect(networks[item1.id]).to.be.an('object')
      expect(networks[item1.id].latitude).to.equal(item1.geometry.coordinates[1])
      expect(networks[item1.id].longitude).to.equal(item1.geometry.coordinates[0])
      expect(networks[item2.id].latitude).to.equal(item2.geometry.coordinates[1])
      expect(networks[item2.id].longitude).to.equal(item2.geometry.coordinates[0])
      done()

  it 'processStations should transform objects', (done) ->
    @station.processStations items, (err, stations) ->
      expect(stations[item1.id]).to.be.an('object')
      expect(stations[item1.id].latitude).to.equal(item1.geometry.coordinates[1])
      expect(stations[item1.id].longitude).to.equal(item1.geometry.coordinates[0])
      expect(stations[item2.id]).be.undefined
      done()

  it 'processStations should handle empty station array', (done) ->
    @station.processStations [], (err, stations) ->
      expect(err).to.be.an.error
      done()

  it 'processStations should handle no available stations', (done) ->
    @station.processStations [item2], (err, stations) ->
      expect(err).to.be.an.error
      done()

  it 'constructResponse should return valid URL', (done) ->
    directions = @station.constructResponse nearestStation
    expect(directions.url).to.contain(nearestStation.latitude)
    expect(directions.url).to.contain(nearestStation.longitude)
    expect(directions.url).to.contain(latitude)
    expect(directions.url).to.contain(longitude)
    expect(validator.isURL directions.url).be.true
    expect(directions.location).be.an('array').with.length(2)
    expect(directions.location[0]).be.a('number')
    expect(directions.location[1]).be.a('number')
    expect(directions.destination).be.an('array').with.length(2)
    expect(directions.destination[0]).be.a('number')
    expect(directions.destination[1]).be.a('number')
    done()

  it 'getNetworks should return cycle hire networks from cache', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, JSON.stringify networks_redis
    result = @station.getNetworks callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.null
    expect(callback.firstCall.args[1]).deep.equal(networks_redis)
    done()

  it 'getNetworks should return cycle hire from upstream API', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, null
    @stub2.yields null, networks_citybikes
    result = @station.getNetworks callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.null
    expect(callback.firstCall.args[1]).have.property(citybikes1.id)
    expect(callback.firstCall.args[1][citybikes1.id].latitude).
      be.equal(citybikes1.geometry.coordinates[1])
    expect(callback.firstCall.args[1][citybikes1.id].longitude).
      be.equal(citybikes1.geometry.coordinates[0])
    expect(callback.firstCall.args[1][citybikes2.id].latitude).
      be.equal(citybikes2.geometry.coordinates[1])
    expect(callback.firstCall.args[1][citybikes2.id].longitude).
      be.equal(citybikes2.geometry.coordinates[0])
    done()

  it 'getNetworks should return error if upstream API fails', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, null
    @stub2.yields new Error, null
    result = @station.getNetworks callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.error
    done()

  it 'getStations should return cycle hire stations from cache', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, JSON.stringify items
    result = @station.getStations nearestNetwork, callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.null
    expect(callback.firstCall.args[1]).deep.equal(items)
    done()

  it 'getStations should return cycle hire stations from API', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, null
    @stub3.callsArgWith 1, null, items
    result = @station.getStations nearestNetwork, callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.null
    expect(callback.firstCall.args[1][item1.id].longitude).
      be.equal(item1.geometry.coordinates[0])
    expect(callback.firstCall.args[1][item1.id].latitude).
      be.equal(item1.geometry.coordinates[1])
    expect(callback.firstCall.args[1][item2.id]).be.undefined
    done()

  it 'getStations should return error if network is too far', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, null
    @stub3.callsArgWith 1, null, items
    result = @station.getStations nearestNetwork2, callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.error
    done()

  it 'getStations should return error if upstream API fails', (done) ->
    callback = sinon.spy()
    @stub1.callsArgWith 1, null, null
    @stub3.callsArgWith 1, new Error, null
    result = @station.getStations nearestNetwork, callback
    expect(callback.calledOnce).be.true
    expect(callback.firstCall.args[0]).be.error
    done()

  afterEach (done) ->
    @station = null
    @stub1.restore()
    @stub2.restore()
    @stub3.restore()
    @stub4.restore()
    @stub5.restore()
    done()

describe 'Model: Station.locate', ->
  req =
    params:
      username: "unittest"
      location: "42.344827;-71.028664"
  user = new User req.params
  nearestNetwork =
    key: 'unittest'
    latitude: 1.1
    longitude: 2.2
    distance: 1234
  nearestStation = nearestNetwork
  mapsUrl = 'https://www.google.com/maps/dir/42.344827,-71.028664/'
  mapsUrl += '1.1,2.2/data=!4m2!4m1!3e2'

  beforeEach ->
    @station = new Station user
    @stub1 = sinon.stub @station, "getNetworks"
    @stub2 = sinon.stub @station, "getStations"
    @stub3 = sinon.stub geolib, "findNearest"
    @callback = sinon.spy()

  it 'should return error if networks cannot be retrieved', (done) ->
    @stub1.yields new Error, null
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.error
    done()

  it 'should return error if geolib fails finding nearestNetwork', (done) ->
    @stub1.yields null, null
    @stub3.throws()
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.error
    done()

  it 'should return error if stations cannot be retrieved', (done) ->
    @stub1.yields null, null
    @stub3.returns nearestNetwork
    @stub2.callsArgWith 1, new Error, null
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.error
    done()

  it 'should return error if stations Object is empty', (done) ->
    @stub1.yields null, null
    @stub2.callsArgWith 1, null, {}
    @stub3.returns nearestNetwork
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.error
    done()

  it 'should return error if geolib fails finding nearestStation', (done) ->
    @stub1.yields null, null
    @stub2.callsArgWith 1, null, nearestStation
    @stub3.onFirstCall().returns(nearestNetwork).onSecondCall().throws()
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.error
    done()

  it 'should return Google Maps URL', (done) ->
    @stub1.yields null, null
    @stub2.callsArgWith 1, null, nearestStation
    @stub3.returns nearestStation
    result = @station.locate @callback
    expect(@callback.calledOnce).be.true
    expect(@callback.firstCall.args[0]).be.null
    expect(@callback.firstCall.args[1].url).be.equal(mapsUrl)
    done()

  afterEach ->
    @callback.reset()
    @stub1.restore()
    @stub2.restore()
    @stub3.restore()
