TCP = require "net"
EventEmitter = require("events").EventEmitter

module.exports = class TCPConnector extends EventEmitter

	constructor: () ->
		@running = false

		@connection = new TCP.Socket()

		@connection.on "error", (error) =>
			#@emit("error", error.code)
			@running = false

	run: (port, address) ->
		@connection.connect port, address, () =>
			@running = true
			@emit("connect", @connection)

	stop: () ->
		@connection.end() if @running
		@running = false