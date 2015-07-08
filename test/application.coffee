require "should"
ServerApplication = require("../").ServerApplication
ClientApplication = require("../").ClientApplication

testingPort = 9999

describe "Application", () ->
  server = null
  client = null

  # configuration folder should be now passed into the application in constructor
  configs = "#{__dirname}/project/configs/"

  afterEach () ->
    client.stop() if client?
    server.stop() if server?

  describe "server construction", () ->
    it "should construct the server instance without any errors", () ->
      server = new ServerApplication(configs)

  describe "client construction", () ->
    it "should construct the client instance without any errors", () ->
      client = new ClientApplication(configs)

  describe "Simple application test", () ->
    it "should connect server and client to each other", (done) ->
      server = new ServerApplication(configs)
      client = new ClientApplication(configs)

      server.config ($connection) ->
        $connection.on "connect", () ->
          client.stop()
          server.stop()
          done()

      server.run(testingPort)
      client.run(testingPort, "127.0.0.1")

  describe "Simple disconnect test", () ->
    it "should connect, disconnect with successful clean of session", (done) ->
      server = new ServerApplication(configs)
      client = new ClientApplication(configs)

      server.config ($connection) ->
        $connection.on "connect", (session) ->
          session.onDisconnect = () ->
            $connection.sessionStorage.should.be.eql([])
            done()
          session.close()

      server.run(testingPort)
      client.run(testingPort, "127.0.0.1")

  describe "Simple application test with ping", () ->
    it "should ping server application from client after connect", (done) ->
      server = new ServerApplication(configs)
      client = null # declaration of client so $router in config can see it

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
          server.stop()
          client.stop()
          done()

        # run after configuration is done, as it may in some time be asynchronous
        server.run(testingPort)

      # due to injections, this must be initialized after first one is configured
      client = new ClientApplication(configs)

      client.config ($connection) ->
        $connection.headPacket [
          opcode: "uint8"
        ]

        $connection.packet "Ping", false, [
          opcode: 0
        , value: "stringle"
        ]

        $connection.on "connect", (session) ->
          session.send "Ping", {
            value: "abc"
          }

        # run after configuration is done, as it may in some time be asynchronous
        client.run(testingPort, "127.0.0.1")
