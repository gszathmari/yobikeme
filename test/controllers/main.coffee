chai = require 'chai'
sinon = require 'sinon'

Station = require '../../src/models/station'
main = require '../../src/controllers/main'
yoclient = require '../../src/helpers/yoclient'

expect = chai.expect

describe 'Controller: index', ->
  # Stub request and response objects
  req = sinon.spy()
  res =
    send: sinon.spy()
  next = sinon.spy()

  it "should respond with 'OK'", ->
    r = main.index req, res, next
    expect(req.called).be.false
    expect(res.send.calledOnce).be.true
    expect(res.send.calledWith "OK").be.true
    expect(next.calledOnce).be.true

  after ->
    req.reset()
    res.send.reset()
    next.reset()

describe 'Controller: hash', ->
  before (done) ->
    # Stub request and response objects
    @req = sinon.spy()
    @res =
      json: sinon.spy()
    @next = sinon.spy()
    @r = main.hash @req, @res, @next
    setTimeout ->
      done()
    , 500

  it "should respond with hash", (done) ->
    expect(@req.called).be.false
    expect(@res.json.calledOnce).be.true
    expect(@res.json.firstCall.args[0]).have.property('hash')
    expect(@res.json.firstCall.args[0].hash).to.be.a('string')
    expect(@next.calledOnce).be.true
    done()

  after ->
    @req.reset()
    @res.json.reset()
    @next.reset()

describe 'Controller: yo', ->
  mapsUrl = "https://www.google.com/maps/dir/0.0,0.0/0.0,0.0/data=!4m2!4m1!3e2"
  helperUrl = "http://bit.ly/yobikeme-help"

  beforeEach ->
    @req =
      params:
        username: "unittest"
        location: "42.344827;-71.028664"
    @req2 =
      params:
        username: "unittest"
    @req3 =
      params:
        username: null
    @res =
      send: sinon.spy()
      json: sinon.spy()
    @next = sinon.spy()
    @stub1 = sinon.stub Station.prototype, "locate"
    @stub2 = sinon.stub yoclient, "send"

  it 'should fail if username was not suppled', (done) ->
    r = main.yo @req3, @res, @next
    expect(@res.send.calledOnce).be.true
    expect(@res.send.firstCall.args[0]).have.property('statusCode')
    expect(@res.send.firstCall.args[0].statusCode).equal(400)
    expect(@next.calledOnce).be.true
    done()

  it 'should return 404 error', (done) ->
    @stub1.yields new Error, null
    r = main.yo @req, @res, @next
    expect(@res.send.calledOnce).be.true
    expect(@res.send.firstCall.args[0]).be.an('object')
    expect(@res.send.firstCall.args[0]).have.property('statusCode')
    expect(@res.send.firstCall.args[0].statusCode).equal(404)
    expect(@next.calledOnce).be.true
    expect(@next.calledWith false).be.true
    done()

  it 'should return Google Maps URL', (done) ->
    @stub1.yields null, mapsUrl
    @stub2.callsArgWith 2, null, null
    r = main.yo @req, @res, @next
    expect(@res.json.calledOnce).be.true
    expect(@res.json.firstCall.args[0]).have.property('success')
    expect(@next.calledOnce).be.true
    done()

  it 'should fail if Yo directions cannot be sent', (done) ->
    @stub1.yields null, mapsUrl
    @stub2.callsArgWith 2, new Error, null
    r = main.yo @req, @res, @next
    expect(@res.send.calledOnce).be.true
    expect(@res.send.firstCall.args[0]).have.property('statusCode')
    expect(@res.send.firstCall.args[0].statusCode).equal(400)
    expect(@next.calledOnce).be.true
    done()

  it 'should return Helper URL', (done) ->
    @stub1.yields null, helperUrl
    @stub2.callsArgWith 2, null, null
    r = main.yo @req2, @res, @next
    expect(@res.json.calledOnce).be.true
    expect(@res.json.firstCall.args[0]).have.property('success')
    expect(@next.calledOnce).be.true
    done()

  it 'should fail if Yo helper cannot be sent', (done) ->
    @stub1.yields null, helperUrl
    @stub2.callsArgWith 2, new Error, null
    r = main.yo @req2, @res, @next
    expect(@res.send.calledOnce).be.true
    expect(@res.send.firstCall.args[0]).have.property('statusCode')
    expect(@res.send.firstCall.args[0].statusCode).equal(400)
    expect(@next.calledOnce).be.true
    done()

  afterEach ->
    @res.send.reset()
    @res.json.reset()
    @next.reset()
    @stub1.restore()
    @stub2.restore()
