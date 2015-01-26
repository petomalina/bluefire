require "should"
TCPConnector = require "../connection/TCPConnector"
TCPAcceptor = require "../connection/TCPAcceptor"

testingPort = 9999

describe "TCPConnector", () ->

	describe "Basic tests", () ->

		it "should construct the tcpconnector correctly", () ->
			connector = new TCPConnector
			(connector?).should.be.true

		it "should try to run the connector", () ->
			connector = new TCPConnector

			connector.run(testingPort, "127.0.0.1")
			connector.running.should.be.false

		it "should try to stop not running connector", () ->
			connector = new TCPConnector
			connector.stop()

describe "TCPAcceptor", () ->

	describe "Basic tests", () ->

		it "should construct the acceptor correctly", () ->
			acceptor = new TCPAcceptor
			(acceptor?).should.be.true

		it "should try to run and stop the acceptor", (done) ->
			acceptor = new TCPAcceptor

			acceptor.on "listening", () ->
				acceptor.running.should.be.true
				acceptor.stop()
				done()

			acceptor.run(testingPort)

		it "should try to stop non running acceptor", () ->
			acceptor = new TCPAcceptor

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