require "should"
Application = require "../Application"

describe "Application", () ->
	server = null
	client = null

	afterEach () ->
		client.stop() if client?
		server.stop() if server?

	describe "server construction", () ->
		it "should construct the server instance without any errors", () ->
			server = new Application(true)

	describe "client construction", () ->
		it "should construct the client instance without any errors", () ->
			client = new Application(false)

	describe "simple application test", () ->
		it "should connect server and client to each other", (done) ->
			server = new Application(true)
			client = new Application(false)

			server.config ($connection) ->
				$connection.on "connect", (session) ->
					done()

			server.run(8888)
			client.run(8888, "127.0.0.1")

	describe "Simple application test with ping", () ->
		it "should ping server application from client after connect", (done) ->
			server = new Application(true)

			server.config ($connection, $router) ->
				$connection.headPacket [
					opcode: "uint8"
				]

				$connection.packet "Ping", false, [
					opcode: 0
				,	value: "stringle"
				]

				$router.route "Ping", (session, data) ->
					(data?).should.be.true
					data["value"].should.eql("abc")
					done()

			client = new Application(false)

			client.config ($connection, $router) ->
				$connection.headPacket [
					opcode: "uint8"
				]

				$connection.packet "Ping", false, [
					value: "stringle"
				]

				$connection.on "connect", (session) ->
					session.send "Ping", {
						opcode: 0
						value: "abc"
					}

			server.run(8888)
			client.run(8888, "127.0.0.1")