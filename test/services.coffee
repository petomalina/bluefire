###
  Tests for:
    services/Services

  @author Gelidus
  @version 0.0.3
###

require("should")
Services = require("../services/Services")
Configuration = require("../config/Configuration")

class TestService

  constructor: () -> # no injections here
    @arg = 5
    @models = { } # names and options

  testMethod: (arg) ->
    return @arg + arg

  testMethodTwo: (@arg) ->

describe "Services", () ->

  describe "#constructor()", () ->
    it "should correctly construct services module", () ->
      services = new Services
      (services?).should.be.true

  describe "#service()", () ->
    it "should add service to the services module", () ->
      services = new Services

      services.service("MyService", TestService) # add service

      service = Injector.getService("MyService")
      (service?).should.be.true
      (service.testMethod?).should.be.true

      service.testMethod(5).should.be.eql(10) # test of methods

    it "should add service and override service that was installed before", () ->
      services = new Services

      services.service("MyService", TestService)
      Injector.getService("MyService").arg = 10
      Injector.getService("MyService").arg.should.be.eql(10)

      services.service("MyService", TestService)
      Injector.getService("MyService").arg.should.be.eql(5)

  # this needs to be redesigned
  describe "#model()", () ->
    services = null
    options = {
      adapters: {
        disk: require("sails-disk")
      }
      connections: {
        disk: {
          adapter: "disk"
        }
      }
      defaults: {
        connection: "disk"
        migrate: "drop"
      }
    }

    mapper = null

    it "should create the service to be able to create models", () ->
      services = new Services
      (services?).should.be.true
      services.service("MyService", TestService)

    it "should add model with default values into mapper", () ->
      services.model "MyModel", {
        attributes: {
          text: "string"
        }
      }

    it "should try to override identity of new model", () ->
      services.model "OtherModel", {
        identity: "model"
        attributes: {
          number: "integer"
        }
      }

    it "should initialize om with sails-disk",(done) ->
      services.initialize options, (err, ontology) ->
        mapper = ontology
        done()

    it "should check models and adapters in mapper", () ->
      (mapper?).should.be.true
      (mapper.collections?).should.be.true
      (mapper.collections.mymodel?).should.be.true
      (mapper.collections.model?).should.be.true # overriden identity

    it "should try to create new model", (done) ->
      mapper.collections.model.create { number: 5 }, (err, model) ->
        mapper.collections.model.findOne { number: 5 }, (err, numberModel) ->
          numberModel.number.should.be.eql(5)
          done()

    it "should try to find all", (done) ->
      mapper.collections.model.find { number: 5 }, (err, numbers) ->
        numbers.length.should.be.eql(1)
        done()

    it "should teardown mapper", (done) ->
      services.objectMapper.teardown (err) ->
        done(err)

  describe "#install()", () ->
    services = null

    it "should construct services instance", () ->
      services = new Services
      (services?).should.be.true

    it "should try to install services", (done) ->

      connectionConfiguration = new Configuration("#{__dirname}/project/configs/connections")

      modelsConfiguration = new Configuration("#{__dirname}/project/configs/models")

      services.install connectionConfiguration, modelsConfiguration, (err) ->
        if not err?
          done()
        else
          done(err)
      , "#{__dirname}/project/models/"

    it "should teardown mapper", (done) ->
      services.objectMapper.teardown (err) ->
        done(err)
