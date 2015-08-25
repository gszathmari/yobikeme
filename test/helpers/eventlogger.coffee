chai = require 'chai'
sinon = require 'sinon'

eventLogger = require '../../src/helpers/eventlogger'

expect = chai.expect

describe 'Helper: eventlogger', ->
  it 'should instatinate the object', (done) ->
    expect(eventLogger).to.respondTo('sendEvent')
    expect(eventLogger).to.respondTo('fireDirections')
    expect(eventLogger).to.respondTo('fireInstructions')
    done()

describe 'Helper: eventlogger (methods)', ->
  beforeEach ->
    @req =
      params:
        username: "unittest"
        ip_address: "127.0.0.1"
    @directions =
      url: "http://maps.google.com/"
      destination: [1.111111, 2.222222]
      location: [3.333333, 4.44444]
    @helperUrl = "http://help.yobikeme.invalid/index.html"
    @stub = sinon.stub eventLogger.client, "addEvent"

  it 'fireDirections should return event', (done) ->
    @stub.callsArgWith 2, null, null
    eventLogger.fireDirections @req, @directions
    expect(@stub.calledOnce).be.true
    expect(@stub.firstCall.args[0]).be.equal("directions")
    expect(@stub.firstCall.args[1]).have.property('user')
    expect(@stub.firstCall.args[1].user).have.property('id')
    expect(@stub.firstCall.args[1].user.id).be.equal(@req.params.username)
    expect(@stub.firstCall.args[1].user).have.property('ip_address')
    expect(@stub.firstCall.args[1].user.ip_address)
      .be.equal(@req.params.ip_address)
    expect(@stub.firstCall.args[1]).have.property('destination')
    expect(@stub.firstCall.args[1].destination).have.property('coordinates')
    expect(@stub.firstCall.args[1].destination.coordinates[0])
      .be.equal(@directions.destination[1])
    expect(@stub.firstCall.args[1]).have.property('keen')
    expect(@stub.firstCall.args[1].keen).have.property('addons')
    expect(@stub.firstCall.args[1].keen.addons).be.an('array').with.length(2)
    expect(@stub.firstCall.args[1].keen).have.property('location')
    expect(@stub.firstCall.args[1].keen.location).have.property('coordinates')
    expect(@stub.firstCall.args[1].keen.location.coordinates[0])
      .be.equal(@directions.location[1])
    expect(@stub.firstCall.args[1]).have.property('yo_url')
    expect(@stub.firstCall.args[1].yo_url).be.equal(@directions.url)
    done()

  it 'fireInstructions should return event', (done) ->
    @stub.callsArgWith 2, null, null
    eventLogger.fireInstructions @req, @helperUrl
    expect(@stub.calledOnce).be.true
    expect(@stub.firstCall.args[0]).be.equal("instructions")
    expect(@stub.firstCall.args[1]).have.property('user')
    expect(@stub.firstCall.args[1].user).have.property('id')
    expect(@stub.firstCall.args[1].user.id).be.equal(@req.params.username)
    expect(@stub.firstCall.args[1].user).have.property('ip_address')
    expect(@stub.firstCall.args[1].user.ip_address)
      .be.equal(@req.params.ip_address)
    expect(@stub.firstCall.args[1]).have.property('keen')
    expect(@stub.firstCall.args[1].keen).have.property('addons')
    expect(@stub.firstCall.args[1].keen.addons).be.an('array').with.length(2)
    expect(@stub.firstCall.args[1]).have.property('yo_url')
    expect(@stub.firstCall.args[1].yo_url).be.equal(@helperUrl)
    done()

  afterEach ->
    @stub.restore()
