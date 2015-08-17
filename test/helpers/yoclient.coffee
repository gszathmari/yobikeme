chai = require 'chai'

yoclient = require '../../src/helpers/yoclient'

expect = chai.expect

describe 'Helper: yoclient', ->
  it 'should have methods', ->
    expect(yoclient).to.respondTo('send')
