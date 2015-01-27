require("should")
Services = require("../services/Services.coffee")

class TestService

  constructor: () -> # no injections here

  testMethod: (arg) ->
    return arg + 5

  testMethodTwo: (arg) ->
    return "#{arg}"

describe "Services", () ->

  describe "#constructor()", () ->
    it "should correctly construct services module", () ->
      services = new Services
      (services?).should.be.true

  describe "#service()", () ->
    it "should add service to the services module", () ->
      services = new Services

      services.service("MyService", TestService) # add service 