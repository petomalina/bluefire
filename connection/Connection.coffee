Session = require '../session/ClientSession'
FileLoader = require '../fileLoader/FileLoader'
Parser = require '../parser/Parser'
Router = require '../routing/Router'
Configuration = require '../config/Configuration'

EventEmitter = require('events').EventEmitter

###
Main server class which stores tcp connection, packets and parser
###
module.exports = class Connection extends EventEmitter

  constructor: (@isServer) ->
    # @property [Object] Parser instance
    @parser = Injector.create(Parser, { isServer : @isServer }) # require default parsr

    # add server as service
    Injector.addService('$connection', @)

    @router = new Router()
    Injector.addService('$router', @router)

    if @isServer
      @connection = new(require('./TCPAcceptor'))
    else
      @connection = new(require('./TCPConnector'))

  install: (@configuration, routerConfiguration, callback) =>
    # create parser and add packets
    parserModuleName = @configuration.get('parser')
    if parserModuleName?
      @parser(parserModuleName, @configuration.get(parserModuleName))

    # if no parser is defined in the configuration, defaukt will be used instead
    try
      packets = require("#{global.CurrentWorkingDirectory}/configs/packets")

      if packets.Head? # register head if found in collection
        @parser.getHead().add(packets.head)

      # register all packets
      for name, packetStructure of packets.ServerPackets
        @packet(name, true, packetStructure)

      for name, packetStructure of packets.ClientPackets
        @packet(name, false, packetStructure)

    catch exception
      console.dir exception
      # no packets found

    # install router
    @router.install(routerConfiguration)

    callback(null, 4)

  ###
  Adds given packet to the parser.
  ###
  packet: (name, isServerPacket, structure) ->
    condition = structure[@conditionField] # get additional condition
    @parser.registerPacket(name, isServerPacket, condition).add(structure)

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

  @param moduleName [String] name of module to be set as a parser
  ###
  parser: (moduleName, options = {}) =>
    parserModule = require(moduleName)
    @parser = Injector.create(parserModule, options)

  ###
  Starts to listen on given port (by argument paseed or configuration)

  @param port [Integer] port to listen on. This will override local configuration
  @param address [String] address to connect to if is client
  ###
  run: (port = null, address = null) =>

    if not @configuration? # repair missing configuration (no install)
      @configuration = new Configuration

    # override the configuration port if other port is specified (non structured approach)
    if port isnt null then @configuration.add('port', port)
    if address isnt null then @configuration.add('address', address)

    @connection.on 'connect', @_onConnect

    runOptions = Injector.resolve(@connection.run, @configuration.data)

    @connection.run(runOptions...)

    #console.log "Running console commander \n"

    ###process.stdin.setEncoding('utf8')

    # look for readable
    process.stdin.on 'readable', () ->
      chunk = process.stdin.read()
      if chunk isnt null
        process.stdout.write('data: ' + chunk)

    # end commander at the end
    process.stdin.on 'end', () ->
      process.stdout.write('Console commander exited')###

  _onConnect: (socket) =>
    do (socket) =>
      session = new Session(socket)

      @emit('connect', session) # emit new connection

      socket.on 'data', (data) =>
        @parser.parse data, (packetName, parsedData) =>
          @router.call packetName, session, data
          @onData(session, packetName, parsedData)

      socket.on 'disconnect', () =>
        socket.destroy()
        @_onDisconnect session

      socket.on 'error', () =>
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