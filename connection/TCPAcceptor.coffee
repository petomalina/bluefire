TCP = require 'net'
EventEmitter = require('events').EventEmitter

module.exports = class TCPAcceptor extends EventEmitter

	constructor: () ->
		@connection = TCP.createServer (socket) =>
			@emit('connect', socket)

	run: (port, address = null) ->
		@connection.listen(port, address)

		console.log "Server is now running on port #{port}"