Configuration = require("../config/").Configuration
ConfigurationManager = require("../config").ConfigurationManager
require("should")

describe "Configuration", () ->
	conf = null

	describe "#constructor()", () ->
		it "should construct the configuration", () ->
			conf = new Configuration

	describe "#add()", () ->
		it "should add key-value pair into configuration", () ->
			conf.add "key", "value"
			conf.add "key2", null
			conf.add "testkey", new Object

			Object.keys(conf.data).length.should.be.exactly(3)

	describe "#get()", () ->
		it "should get key-value pair from configuration", () ->
			"value".should.eql(conf.get("key"))
			(conf.get("testkey") is null).should.not.be.true

		it "should try to retrieve the null value from key", () ->
			(conf.get("key2") is null).should.be.true

	describe "#length", () ->
		it "should return length of current configuration", () ->
			Object.keys(conf.data).length.should.be.eql(conf.length())

	describe "#remove()", () ->
		it "should remove key-value pair from configuration", () ->
			conf.remove "key2"
			conf.length().should.be.eql(2)
			conf.remove "key"
			(conf.get("key") is null).should.not.be.true

		it "should try to remove non-existing key", () ->
			conf.remove("key2") # no error should be here

	describe "#empty()", () ->
		it "should return false if configuration is empty and if not, empty it", () ->
			conf.empty().should.be.false
			conf.remove "testkey"

		it "should check the configuration if it\"s empty (is empty)", () ->
			conf.empty().should.be.true
			
describe "ConfigurationManager", () ->
	
	describe "#constructor()", () ->
		it "should correctly construct configuration manager", () ->
			manager = new ConfigurationManager(__dirname + "/project/configs")
			(manager.baseDir?).should.be.true
			
		it "should try to construct configuration manager without base dir", (done) ->
			try
				manager = new ConfigurationManager
			catch exception
				done()
				
	describe "#load()", () ->
		manager = null
		
		it "should initialize manager correctly", () ->
			manager = new ConfigurationManager(__dirname + "/project/configs")
			
		it "should try to load all files from project configs", (done) ->
			manager.load (err) ->
				manager.get("config").should.be.instanceOf(Configuration)
				manager.get("connections").should.be.instanceOf(Configuration)
				manager.get("models").should.be.instanceOf(Configuration)
				done()