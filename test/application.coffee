require "should"
ServerApplication = require("../").ServerApplication
ClientApplication = require("../").ClientApplication

testingPort = 9999

describe "Application", () ->
  server = null
  client = null
  
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

  describe "simple application test", () ->
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

  describe "Simple application test with ping", () ->
    it "should ping server application from client after connect", (done) ->
      server = new ServerApplication(configs)
      client = null

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
          
        server.run(testingPort)
        
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
          
        client.run(testingPort, "127.0.0.1")