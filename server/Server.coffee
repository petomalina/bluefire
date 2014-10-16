TCP = require 'net'
Session = require '../session/ClientSession'
FileLoader = require '../fileLoader/FileLoader'

module.exports = class Server

  constructor: (@configuration) ->

  install: (callback) =>

    # create parser and add packets
    Parser = require @configuration.get 'parser'
    args = Injector.resolve Parser, @configuration.get(@configuration.get 'parser')
    @parser = new Parser args... # create parser

    @_installPackets()

    @server = TCP.createServer()

    console.log 'Server Initialized'
    callback(null, 1)

  _installPackets: () =>
    packets = require 'application/configs/packets'

    if packets.head?
      @parser.registerHead().add(packets.head)

    # register all packets
    for name, packetStructure of packets
      continue if name is 'head'

      condition = null
      if packetStructure[@parser.conditionField]?
        condition = packetStructure[@parser.conditionField]
        delete packetStructure[@parser.conditionField]

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

      socket.on 'disconnect', () ->
        self._onDisconnect(@getSession())

      @onConnect(session)

  onConnect: (session) =>
    # virtual method - override this when needed

  _onDisconnect: (socket) =>
    # virtual method - override this when needed

  _onData: (socket, packetName, data) =>
    # virtual method - override this when needed