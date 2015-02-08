Injector = require "../di/Injector"
require "should"

describe "Injector", () ->
	injector = null

	describe "#constructor()", () ->
		it "should correclty construct injector", () ->
			injector = new Injector
			(injector?).should.be.ok

	describe "#getArguments()", () ->
		it "should return array of arguments that should be passed into the function", () ->
			functionOne = () -> # no args
			functionTwo = (a, b) ->
			functionThree = (a, b = 0, c = null) ->

			[].should.eql(injector.getArguments(functionOne))
			["a", "b"].should.eql(injector.getArguments(functionTwo))
			["a", "b", "c"].should.eql(injector.getArguments(functionThree))

	describe "#addFactory()", () ->
		it "should add factory into the injector", () ->
			factory = () ->
				return { one: 1, two: 2 }

			injector.addFactory("myService", factory)

			(injector.factories["myService"]?).should.be.ok
			Object.keys(injector.services).length.should.be.eql(0) # lazy load test

	describe "#addService()", () ->
		it "should add service into the injector", () ->
			service = { serviceWithoutFactory: true }

			injector.addService("service", service)

			(injector.services["service"]?).should.be.ok

	describe "#getService()", () ->
		it "should return service from the injector", () ->
			(injector.getService("service")?).should.be.true # get just service

			(injector.getService("myService")?).should.be.true # get service from factory
			Object.keys(injector.services).length.should.be.eql(2) # should have also factory created service now

	describe "#resolve()", () ->
		it "should return dependencies of function", () ->
			functionOne = (a, b) ->
			functionTwo = (service, myService) ->

			([1,2]).should.eql(injector.resolve(functionOne, {a:1, b:2}))

			dependencies = injector.resolve(functionTwo)
			dependencies.should.have.length(2)
			dependencies[0].	should.eql({ serviceWithoutFactory: true})
			dependencies[1].should.eql({one: 1, two: 2})

	describe "#create()", () ->
		it "should create injected instance of given constructor", () ->
			constr = (service) ->
				this.service = service

			instance = injector.create(constr)

			instance.should.be.an.instanceOf(constr)
			instance.service.should.be.ok