chai = require 'chai'

newrelic = require '../../src/helpers/newrelic'

expect = chai.expect

describe 'Helper: newrelic', ->
  it 'should not create a newrelic object', ->
    expect(newrelic).to.be.undefined
