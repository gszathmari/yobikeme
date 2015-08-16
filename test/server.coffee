chai = require 'chai'

app = require '../src/server'

expect = chai.expect

describe 'routes', ->
  it 'should create restify app', ->
    expect(app).be.an('object')
