TCP = require 'net'
Session = require '../session/ClientSession'
FileLoader = require '../fileLoader/FileLoader'
Parser = require '../parser/Parser'


###
Main server class which stores tcp connection, packets and parser
###
module.exports = class Server

  constructor: () ->
    # @property [Object] Parser instance
    @parser = new (require('../parser/Parser')) # require default parsr

    Injector.addService('$server', @)

  install: (@configuration, callback) =>
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

    @server = TCP.createServer()

    callback(null, 4)

  ###
  Adds given packet to the parser.
  ###
  packet: (name, isServerPacket, structure) ->
    condition = structure[@conditionField] # get additional condition
    @parser.registerPacket(name, isServerPacket, condition).add(structure)

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
  ###
  run: (port = null) =>
    @server.on 'connection', @_onConnect

    # override the configuration port if other port is specified (non structured approach)
    port = if port is null then @configuration.get 'port' else port

    @server.listen(port)
    console.log "Server is now running on port: #{port}"

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

      socket.on 'data', (data) =>
        @parser.parse data, (packetName, parsedData) =>
          @_onData(session, packetName, parsedData)

      socket.on 'disconnect', () =>
        socket.destroy()
        @_onDisconnect session

      socket.on 'error', () =>
        console.log "Error on socket, disconnecting ..."
        socket.destroy()
        @_onDisconnect session

      @onConnect(session)

  onConnect: (session) ->
    console.log 'connect'
    # virtual method - override this when needed

  _onDisconnect: (socket) ->
    # virtual method - override this when needed

  _onData: (socket, packetName, data) =>
    # virtual method - override this when needed