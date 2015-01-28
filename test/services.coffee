###
  Tests for:
    services/Services

  @author Gelidus
  @version 0.0.3
###

require("should")
Services = require("../services/Services.coffee")

class TestService

  constructor: () -> # no injections here
    @arg = 5
    @models = { } # names and options

  testMethod: (arg) ->
    return @arg + arg

  testMethodTwo: (@arg) ->

  def: (name, options) ->
    @models[name] = options
    return false # just to keep difference

  define: (name, options) ->
    @models[name] = options
    return true

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

  describe "#model()", () ->
    services = null

    it "should create the service to be able to create models", () ->
      services = new Services
      (services?).should.be.true
      services.service("MyService", TestService)

    it "should add model to the created service", () ->
      res = services.model("MyModel", { a: 5, b: 6 } , "MyService", "def")
      (res?).should.be.true
      res.should.be.false

    it "should test predefined register function", () ->
      res = services.model("MyModel", { a: 7, b: 8}, "MyService")
      (res?).should.be.true
      res.should.be.true

  describe "#install()", () ->