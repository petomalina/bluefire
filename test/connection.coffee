require "should"
TCPConnector = require("../connection/TCPConnector")
TCPAcceptor = require("../connection/TCPAcceptor")
Connection = require("../connection/Connection")
Configuration = require("../config/Configuration")

testingPort = 9999

describe "TCPConnector", () ->

	describe "Basic tests", () ->
		connector = null

		it "should construct the tcpconnector correctly", () ->
			connector = new TCPConnector
			(connector?).should.be.true

		it "should try to run the connector", () ->
			connector.run(testingPort, "127.0.0.1")
			connector.running.should.be.false

		it "should stop running connector", () ->
			connector.stop()

		it "should try to stop not running connector", () ->
			connector.stop()

describe "TCPAcceptor", () ->

	describe "Basic tests", () ->
		acceptor = null

		it "should construct the acceptor correctly", () ->
			acceptor = new TCPAcceptor
			(acceptor?).should.be.true

		it "should try to run and stop the acceptor", (done) ->
			acceptor.on "listening", () ->
				acceptor.running.should.be.true
				acceptor.stop()
				done()

			acceptor.run(testingPort)

		it "should stop running acceptor", () ->
			acceptor.stop()

		it "should try to stop non running acceptor", () ->
			acceptor.stop()

describe "TCPAcceptor and TCPConnector cooperation", () ->

	describe "Basic tests", () ->

		it "should connect both to each other", (done) ->
			acceptor = new TCPAcceptor
			connector = new TCPConnector

			acceptor.on "connect", () ->
				connector.stop()
				acceptor.stop()
				done()

			acceptor.on "listening", () ->
				connector.run(testingPort, '127.0.0.1')

			acceptor.run(testingPort)

describe "Connection", () ->

	describe "#constructor", () ->
		it "should correctly construct connection instance", () ->
			connection = new Connection(true)
			(connection?).should.be.true
			connection.isServer.should.be.true
			connection.sessionStorage.should.be.eql([])

			(connection.parser.conditionField?).should.be.true
			connection.parser.conditionField.should.be.eql("opcode")

	describe "#install()", () ->
		connection = null

		it "should construct server connection instance", () ->
			connection = new Connection(true)
			(connection?).should.be.true

		it "should correctly install packetbuddy from config", (done) ->
			config = new Configuration
			config.load("./configs/config.coffee")

			routerConfig = new Configuration

			connection.install config, routerConfig, (err, result) ->
				done()


	describe "Unexpected socket error", () ->
		connection = null
		socket = null

		it "should construct server connection instance", () ->
			connection = new Connection(true)
			(connection?).should.be.true

		it "should listen for the socket connection", (done) ->
			connection.run(testingPort)

			connection.on "error", () ->
				connection.stop()

			connection.on "close", () =>
				#throw new Error("Connection should be handled by error, not close")
				connection.stop()
				done()

			socket = new (require("net")).Socket()
			socket.connect(testingPort, "127.0.0.1")
			socket.end()
