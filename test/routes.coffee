chai = require 'chai'

app = require '../src/server'
routes = require '../src/routes'

expect = chai.expect

describe 'routes', ->
  it 'should have registered routes', ->
    expect(app.routes).to.have.property('head')
    expect(app.routes).to.have.property('get')
    expect(app.routes).to.have.property('gethash')
    expect(app.routes).to.have.property('getyo')
