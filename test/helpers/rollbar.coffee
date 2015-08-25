chai = require 'chai'

rollbar = require '../../src/helpers/rollbar'

expect = chai.expect

describe 'Helper: rollbar', ->
  it 'should have methods', (done) ->
    expect(rollbar).be.an('object')
    expect(rollbar).have.property('api')
    expect(rollbar.api).have.property('endpoint')
    expect(rollbar.api.endpoint).to.contain("api.rollbar.com")
    done()
