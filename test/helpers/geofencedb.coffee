chai = require 'chai'

geofencedb = require '../../src/helpers/geofencedb'

expect = chai.expect

describe 'Helper: geofencedb', ->
  it 'should be an object with data', ->
    expect(geofencedb).to.be.an('object')
    expect(geofencedb).have.property('manhattan')
    expect(geofencedb.manhattan).have.property('points')
    expect(geofencedb.manhattan.points).be.an('array')
    expect(geofencedb.manhattan).have.property('name')
    expect(geofencedb.manhattan.name).equal('citi-bike-nyc')
