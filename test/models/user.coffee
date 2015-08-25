chai = require 'chai'
sinon = require 'sinon'

User = require '../../src/models/user'

expect = chai.expect

describe 'Model: User', ->
  describe 'should be a valid object', ->
    req =
      params:
        username: "unittest"
        user_ip: "127.0.0.1"
        location: "-2.3124343;121.2325232"
    user = new User req.params

    it 'should respond to its methods', (done) ->
      expect(user).to.respondTo('sanitize')
      expect(user).to.respondTo('validate')
      expect(user).to.respondTo('getId')
      expect(user).to.respondTo('getIP')
      expect(user).to.respondTo('getLocation')
      expect(user).to.respondTo('isValid')
      expect(user).to.respondTo('get')
      expect(user).to.respondTo('set')
      done()

    it 'validate method should return null', (done) ->
      expect(user.validate req.params).be.null
      done()

    it 'sanitize should return the same data', (done) ->
      expect(user.sanitize req.params).be.deep.equal(req.params)
      done()

    it 'should return the username', (done) ->
      id = user.getId()
      expect(id).to.equal(req.params.username)
      done()

    it 'should return the IP address', (done) ->
      ip = user.getIP()
      expect(ip).to.equal(req.params.user_ip)
      done()

    it 'should return the coordinates', (done) ->
      original = req.params.location.split ';'
      coordinates = user.getLocation()
      expect(coordinates.latitude).to.equal(original[0])
      expect(coordinates.longitude).to.equal(original[1])
      done()

    it 'getter should retrieve added by the setter', (done) ->
      key = "unit"
      value = "test"
      user.set key, value
      expect(user.get key).be.equal(value)
      done()

  describe 'should validate the username parameter', ->
    req =
      params:
        username: new String
        user_ip: "127.0.0.1"
        location: "-2.3124343;121.2325232"
    user = new User req.params

    it 'should return error', (done) ->
      user.isValid (err) ->
        expect(err).to.be.an.error
        done()

  describe 'should validate the user_ip parameter', ->
    req =
      params:
        username: "unittest"
        user_ip: "invalid"
        location: "-2.3124343;121.2325232"
    user = new User req.params

    it 'should return error', (done) ->
      user.isValid (err) ->
        expect(err).to.be.an.error
        done()

  describe 'should validate the location parameter', ->
    req1 =
      params:
        username: "unittest"
        user_ip: "127.0.0.1"
        location: "invalid"
    req2 =
      params:
        username: "unittest"
        user_ip: "127.0.0.1"
        location: "-222.3124343;121.2325232"
    req3 =
      params:
        username: "unittest"
        user_ip: "127.0.0.1"
        location: "-2.3124343;-321.2325232"
    user1 = new User req1.params
    user2 = new User req2.params
    user3 = new User req3.params

    it 'test1 should return error', (done) ->
      user1.isValid (err) ->
        expect(err).to.be.an.error
        done()

    it 'test2 should return error', (done) ->
      user2.isValid (err) ->
        expect(err).to.be.an.error
        done()

    it 'test3 should return error', (done) ->
      user3.isValid (err) ->
        expect(err).to.be.an.error
        done()
