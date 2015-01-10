assert = require("assert")
Injector = require '../di/Injector'
require 'should'

describe 'Injector', () ->
	injector = Injector

	describe '#getArguments()', () ->
		it 'should return array of arguments that should be passed into the function', () ->
			functionOne = () -> # no args
			functionTwo = (a, b) ->
			functionThree = (a, b = 0, c = null) ->

			[].should.eql(injector.getArguments(functionOne))
			['a', 'b'].should.eql(injector.getArguments(functionTwo))
			['a', 'b', 'c'].should.eql(injector.getArguments(functionThree))

	describe '#addFactory()', () ->
		it 'should add factory into the injector', () ->
			factory = () ->
				return { one: 1, two: 2 }

			injector.addFactory('myService', factory)

			assert.notEqual(null, injector.factories['myService'])
			assert.equal(0, Object.keys(injector.services)) # lazy load test

	describe '#addService()', () ->
		it 'should add service into the injector', () ->
			service = { serviceWithoutFactory: true }

			injector.addService('service', service)

			assert.notEqual(null, injector.services['service'])

	describe '#getService()', () ->
		it 'should return service from the injector', () ->
			assert.notEqual(null, injector.getService('service')) # get just service

			assert.notEqual(null, injector.getService('myService')) # get service from factory
			assert.equal(2, Object.keys(injector.services).length) # should have also factory created service now

	describe '#resolve()', () ->
		it 'should return dependencies of function', () ->
			functionOne = (a, b) ->
			functionTwo = (service, myService) ->

			([1,2]).should.eql(injector.resolve(functionOne, {a:1, b:2}))

			dependencies = injector.resolve(functionTwo)
			dependencies.should.have.length(2)
			dependencies[0].should.eql({ serviceWithoutFactory: true})
			dependencies[1].should.eql({one: 1, two: 2})

	describe '#create()', () ->
		it 'should create injected instance of given constructor', () ->
			constr = (@service) ->

			instance = injector.create(constr)

			instance.should.be.an.instanceOf(constr)
			instance.service.should.be.ok