chai = require 'chai'
sinon = require 'sinon'
validator = require 'validator'
citybikes = require 'citybikes-js'

Station = require '../../src/models/station'
redis = require '../../src/helpers/redis'

expect = chai.expect

describe 'Model: Station', ->
  location = "42.344827;-71.028664"
  latitude = "42.344827"
  longitude = "-71.028664"
  nearestStation =
    latitude: "12.343109"
    longitude: "20.023661"
  item1 =
    id: "abc123"
    geometry:
      coordinates: ["43.344827", "-70.028664"]
  item2 =
    id: "xyz987"
    geometry:
      coordinates: ["12.343109", "20.023661"]
  items = [item1, item2]
  error = new Error "Unit test error, please ignore"

  beforeEach ->
    @station = new Station location
    @stub1 = sinon.stub redis, "get"
    @stub2 = sinon.stub citybikes, "networks"
    @stub3 = sinon.stub citybikes, "stations"
    @stub4 = sinon.stub redis, "set"
    @stub5 = sinon.stub redis, "expire"
    @stub1.yields null, null

  it 'constructor should instatinate object', (done) ->
    expect(@station.coordinates).to.be.an('object')
    expect(@station.coordinates.latitude).to.be.equal(latitude)
    expect(@station.coordinates.longitude).to.be.equal(longitude)
    done()

  it 'processItems should transform objects', (done) ->
    result = @station.processItems(items)
    expect(result[item1.id]).to.be.an('object')
    expect(result[item1.id].latitude).to.equal(item1.geometry.coordinates[1])
    expect(result[item2.id].longitude).to.equal(item2.geometry.coordinates[0])
    expect(result[item2.id].latitude).to.equal(item2.geometry.coordinates[1])
    expect(result[item2.id].longitude).to.equal(item2.geometry.coordinates[0])
    done()

  it 'constructUrl should return valid URL', (done) ->
    mapsUrl = @station.constructUrl nearestStation
    expect(mapsUrl).to.contain(nearestStation.latitude)
    expect(mapsUrl).to.contain(nearestStation.longitude)
    expect(mapsUrl).to.contain(latitude)
    expect(mapsUrl).to.contain(longitude)
    expect(validator.isURL mapsUrl).be.true
    done()

  it 'locate should return nearest location', (done) ->
    @stub2.yields null, items
    @stub3.yields null, items
    @station.locate (err, mapsUrl) ->
      expect(mapsUrl).to.contain(latitude)
      expect(mapsUrl).to.contain(longitude)
      expect(mapsUrl).to.contain(item2.geometry.coordinates[0])
      expect(mapsUrl).to.contain(item2.geometry.coordinates[1])
      expect(validator.isURL mapsUrl).be.true
      done()

  it 'locate should throw error if "networks" throws error', (done) ->
    @stub2.yields error, null
    @stub3.yields null, null
    @station.locate (err, mapsUrl) ->
      expect(err).be.equal(error)
      expect(mapsUrl).be.null
      done()

  it 'locate should throw error if "stations" throws error', (done) ->
    @stub2.yields null, items
    @stub3.yields error, null
    @station.locate (err, mapsUrl) ->
      expect(err).be.equal(error)
      expect(mapsUrl).be.null
      done()

  it 'locate should throw error if coordinates are invalid', (done) ->
    @stub2.yields null, items
    @stub3.yields null, items
    badLocation = "aaa;bbb"
    station2 = new Station badLocation
    station2.locate (err, mapsUrl) ->
      expect(err.message).to.contain("nearest networks with geolib")
      expect(mapsUrl).be.null
      done()

  afterEach (done) ->
    @station = null
    @stub1.restore()
    @stub2.restore()
    @stub3.restore()
    @stub4.restore()
    @stub5.restore()
    done()
