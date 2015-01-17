TCP = require 'net'
EventEmitter = require('events').EventEmitter

module.exports = class TCPAcceptor extends EventEmitter

	constructor: () ->
		@running = false

		@connection = TCP.createServer (socket) =>
			@emit('connect', socket)

	run: (port, address = null) ->
		@connection.listen(port, address)
		@running = true

	stop: () ->
		@connection.close() if @running
		@running = false