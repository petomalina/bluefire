try
  Session = require("#{global.CurrentWorkingDirectory}/sessions/Session")
catch exception
  Session = require("../session/Session")

Parser = require("../parser/Parser")
Router = require("../routing/Router")
Configuration = require("../config/Configuration")
Protocol = require("./Protocol")

EventEmitter = require("events").EventEmitter

###
  Main server class which stores tcp connection, packets and parser
###
module.exports = class Connection extends EventEmitter

  constructor: (@isServer) ->
    @sessionStorage = []

    # add server as service
    Injector.addService("$connection", @)

    @protocol = new Protocol() # create new protocol and add it to injector
    Injector.addService("$protocol", @protocol)

    # @property [Object] Parser instance
    @parser = new Parser(@isServer) # require default parsr
    @parser.initialize() # initialize with defaults

    @router = new Router()
    Injector.addService("$router", @router)

    if @isServer
      @connection = new(require("./TCPAcceptor"))
    else
      @connection = new(require("./TCPConnector"))

  install: (@configuration, routerConfiguration, callback) =>
    # create parser and add packets
    parserModuleName = @configuration.get("parser")
    if parserModuleName? and parserModuleName isnt "packetbuddy"
      @setParser(parserModuleName, @configuration.get(parserModuleName))
    else if parserModuleName is "packetbuddy"
      @setParser(@parser, @configuration.get(parserModuleName))

    # if no parser is defined in the configuration, defaukt will be used instead
    try
      packets = require("#{global.CurrentWorkingDirectory}/configs/packets")

      if packets.Head? # register head if found in collection
        @parser.getHead().add(packets.Head)

      # register all packets
      for name, packetStructure of packets.ServerPackets
        @packet(name, true, packetStructure)

      for name, packetStructure of packets.ClientPackets
        @packet(name, false, packetStructure)

    catch exception # this is optional, use debug mode to log
      # console.log "Packet install exception: #{exception}"
      # no packets found

    # install router
    @router.install(routerConfiguration)

    callback(null, 4)

  ###
  Adds given packet to the parser.
  ###
  packet: (name, isServerPacket, structure) ->
    @parser.packet(name, isServerPacket, structure).add(structure)

  ###
    Adds structure to the parser head packet

    @param structure [Object] structure of the head packet
    @return [Packet] current head packet
  ###
  headPacket: (structure) ->
    @parser.getHead().add(structure)
    return @parser.getHead()

  ###
    Replaces the current packet parser with new module

    @param module [String|Parser] name of module to be set as a parser
  ###
  setParser: (module, options = {}) =>
    if typeof module is "string"
      ParserModule = require(module)
      @parser = new ParserModule(@isServer)
    else
      @parser = module

    args = Injector.resolve(@parser.initialize, options)
    @parser.initialize(args...)

  ###
    Starts to listen on given port (by argument paseed or configuration)

    @param port [Integer] port to listen on. This will override local configuration
    @param address [String] address to connect to if is client
  ###
  run: (port = null, address = null) =>

    if not @configuration? # repair missing configuration (no install)
      @configuration = new Configuration

    # override the configuration port if other port is specified (non structured approach)
    if port isnt null then @configuration.add("port", port)
    if address isnt null then @configuration.add("address", address)

    @connection.on "connect", @_onConnect

    runOptions = Injector.resolve(@connection.run, @configuration.data)

    @connection.run(runOptions...)

    #console.log "Running console commander \n"

    ###process.stdin.setEncoding("utf8")

    # look for readable
    process.stdin.on "readable", () ->
      chunk = process.stdin.read()
      if chunk isnt null
        process.stdout.write("data: " + chunk)

    # end commander at the end
    process.stdin.on "end", () ->
      process.stdout.write("Console commander exited")###

  ###
    Stops current connection system, disabling it to send or receive
    data. Connection must be then established once more to get working
  ###
  stop: () ->
    @connection.stop()

  removeSession: (session) =>
    index = @sessionStorage.indexOf(session)
    @sessionStorage.splice(index, 1) if index isnt -1

  _onConnect: (socket) =>
    do (socket) =>
      session = new Session
      session.initialize(socket, @parser)

      # save session into the array
      @sessionStorage.push(session)

      @protocol.initializeSession(session) # initialize session for current protocol

      @emit("connect", session) # emit new connection

      socket.on "data", (buffer) =>
        @protocol.receive buffer, session, (data) =>
          @parser.parse data, (packetName, parsedData) =>
            @router.call packetName, session, parsedData
            @onData(session, packetName, parsedData)

      socket.on "disconnect", () =>
        @removeSession(session) # remove current session from storage
        socket.destroy()
        @_onDisconnect session

      socket.on "error", () =>
        console.log "Error on socket, disconnecting ..."
        socket.destroy()
        @_onDisconnect session

      @onConnect(session)

  onConnect: (session) ->
    # virtual method - override this when needed

  _onDisconnect: (socket) ->
    # virtual method - override this when needed

  onData: (session, packetName, data) =>
    # virtual method - override this when needed
