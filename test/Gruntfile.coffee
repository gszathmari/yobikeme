chai = require 'chai'

Gruntfile = require '../Gruntfile'

expect = chai.expect

describe 'Gruntfile', ->
  it 'should be a valid function', ->
    expect(Gruntfile).to.be.an('function')
