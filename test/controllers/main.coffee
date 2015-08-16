chai = require 'chai'
sinon = require 'sinon'

main = require '../../src/controllers/main'

expect = chai.expect

describe 'Controller: index', ->
  # Stub request and response objects
  req = sinon.spy()
  res =
    send: sinon.spy()
  next = sinon.spy()

  it "should return the 'OK' message", ->
    r = main.index req, res, next
    expect(req.called).be.false
    expect(res.send.calledOnce).be.true
    expect(res.send.calledWith "OK").be.true
    expect(next.calledOnce).be.true

  after ->
    req.reset()
    res.send.reset()
    next.reset()
