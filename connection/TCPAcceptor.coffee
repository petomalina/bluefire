TCP = require 'net'
EventEmitter = require('events').EventEmitter

module.exports = class TCPAcceptor extends EventEmitter

  constructor: () ->
    @running = false

    @connection = TCP.createServer (socket) =>
      @emit('connect', socket)

    @connection.on "listening", () =>
      @running = true
      @emit("listening")

  run: (port, address = null) ->
    @connection.listen(port, address)

  stop: () ->
    @connection.close() if @running
    @running = false