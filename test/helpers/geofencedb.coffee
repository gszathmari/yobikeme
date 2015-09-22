chai = require 'chai'

geofencedb = require '../../src/helpers/geofencedb'

expect = chai.expect

describe 'Helper: geofencedb', ->
  it 'should be an object with data', ->
    expect(geofencedb).to.be.an('array')
    expect(geofencedb).have.length.at.least(1)
    expect(geofencedb[0]).have.property('name')
    expect(geofencedb[0]).have.property('points')
    expect(geofencedb[0].points).be.an('array')
    expect(geofencedb[0]).have.property('description')
