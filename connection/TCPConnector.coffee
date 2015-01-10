TCP = require 'net'
EventEmitter = require('events').EventEmitter

module.exports = class TCPConnector extends EventEmitter

	constructor: () ->
		@connection = new TCP.Socket()

	run: (port, address) ->
		@connection.connect port, address, () =>
			@emit('connect', @connection)