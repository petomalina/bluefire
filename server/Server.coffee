TCP = require 'net'
Session = require '../session/ClientSession'
FileLoader = require '../fileLoader/FileLoader'
Parser = require '../parser/Parser'


###

###
module.exports = class Server

  constructor: (@configuration) ->
    # @property [Object] Parser instance
    @parser = new (require('../parser/Parser')) # require default parsr

    Injector.addService('$server', @)

  install: (callback) =>
    # create parser and add packets
    parserModuleNmae = @configuration.get('parser')
    if parserModuleNmae?
      Parser = require parserModuleNmae
      args = Injector.resolve Parser, @configuration.get(parserModuleNmae)
      @parser = new Parser args... # create parser

      # packets can't be installed without parser
      @_installPackets()

    @server = TCP.createServer()

    console.dir "here"

    callback(null, 4)

  ###
  Adds given packet to the parser.
  ###
  packet: (name, structure) ->


  ###
  Replaces the current packet parser with new module

  @param moduleName [String] name of module to be set as a parser
  ###
  parser: (moduleName) =>
    @parser = new (require(moduleName))

  _installPackets: () =>
    packets = require 'application/configs/packets'

    if packets.head?
      @parser.registerHead().add(packets.head)

    # register all packets
    for name, packetStructure of packets
      continue if name is 'head'

      condition = null
      if packetStructure[@parser.conditionField]? # register additional condition to parser
        condition = packetStructure[@parser.conditionField]
        #delete packetStructure[@parser.conditionField]

      @parser.registerPacket(name, condition).add(packetStructure)

  run: () =>
    @server.on 'connection', @_onConnect

    @server.listen @configuration.get 'port'
    console.log('Server is now running on port: ' + @configuration.get 'port')

  _onConnect: (socket) =>
    do (socket) =>
      session = new Session(socket)

      socket.on 'data', (data) =>
        @parser.parse data, (packetName, parsedData) =>
          @_onData(session, packetName, parsedData)

      socket.on 'disconnect', () =>
        @_onDisconnect session

      socket.on 'error', () =>
        console.log 'Error on socket, disconnecting ...'
        #socket.destroy()
        @_onDisconnect session

      @onConnect(session)

  onConnect: (session) ->
    console.log 'connect'
    # virtual method - override this when needed

  _onDisconnect: (socket) ->
    # virtual method - override this when needed

  _onData: (socket, packetName, data) =>
    # virtual method - override this when needed