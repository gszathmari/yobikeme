chai = require 'chai'

redis = require '../../src/helpers/redis'

expect = chai.expect

describe 'Helper: redis', ->
  it 'should create redis object', ->
    expect(redis).to.have.property('ready')
