chai = require 'chai'
sinon = require 'sinon'
request = require 'request'

Station = require '../../src/models/station'
main = require '../../src/controllers/main'

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

describe 'Controller: yo', ->
  mapsUrl = "https://www.google.com/maps/dir/0.0,0.0/0.0,0.0/data=!4m2!4m1!3e2"

  beforeEach ->
    @req =
      params:
        username: "unittest"
        location: "42.344827;-71.028664"
    @res =
      send: sinon.spy()
      status: sinon.spy()
      json: sinon.spy()
    @next = sinon.spy()
    @stub1 = sinon.stub Station.prototype, "locate"
    @stub2 = sinon.stub request, "post"

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

  it 'should return 502 error', (done) ->
    @stub1.yields null, mapsUrl
    @stub2.callsArgWith 1, new Error, null, null
    r = main.yo @req, @res, @next
    expect(@res.send.calledOnce).be.true
    expect(@res.send.firstCall.args[0]).be.an('object')
    expect(@res.send.firstCall.args[0]).have.property('statusCode')
    expect(@res.send.firstCall.args[0].statusCode).equal(400)
    expect(@next.calledOnce).be.true
    expect(@next.calledWith false).be.true
    done()

  it 'should return Google Maps URL', (done) ->
    response =
      statusCode: 200
    body =
      success: true
    @stub1.yields null, mapsUrl
    @stub2.callsArgWith 1, null, response, JSON.stringify body
    r = main.yo @req, @res, @next
    expect(@res.json.calledOnce).be.true
    expect(@res.json.firstCall.args[0]).have.property('success')
    expect(@res.status.calledOnce).be.true
    expect(@res.status.firstCall.args[0]).equal(response.statusCode)
    expect(@next.calledOnce).be.true
    done()

  it 'should return Helper URL', (done) ->
    response =
      statusCode: 200
    body =
      success: true
    req =
      params:
        username: "unittest"
    helperUrl = "http://bit.ly/yobikeme-help"
    @stub1.yields null, helperUrl
    @stub2.callsArgWith 1, null, response, JSON.stringify body
    r = main.yo req, @res, @next
    expect(@res.json.calledOnce).be.true
    expect(@res.json.firstCall.args[0]).have.property('success')
    expect(@res.status.calledOnce).be.true
    expect(@res.status.firstCall.args[0]).equal(response.statusCode)
    expect(@next.calledOnce).be.true
    done()

  afterEach ->
    @res.send.reset()
    @res.status.reset()
    @res.json.reset()
    @next.reset()
    @stub1.restore()
    @stub2.restore()
