Packet = require('./Packet')

module.exports = class Parser

	constructor: (@conditionField = 'opcode') ->
		@head = new Packet("Head") # register empty head

		@packetCollection = { } # packet collection
		@packetConditions = { } # condition - name map

	###
	@return [Packet] packet representing head for all packets
	###
	getHead: () ->
		return @packetHead

	###
	Sets the condition field to the custom one

	@param conditionField[String] name of condition field in packet
	###
	setConditionField:(@conditionField) ->

	###
	Registers 
	###
	registerPacket: (packetName, condition = null) =>
		packet = new Packet(packetName, @packetHead)

		@packetCollection[packetName] = packet

		# register condition for current packet
		@registerCondition(packetName, condition)

		return packet

	getPacket: (packetName) ->
		return @packetCollection[packetName]

	registerCondition: (packetName, condition = null) ->
		if condition? and packetName?
			@packetConditions[condition] = packetName 			

	parse: (data, callback, packetName = null) ->
		buffer = new Buffer(data)

		parsedData = { }
		head = @getHead()
		index = 0 # current byte index for parser

		# read whole head
		for parser in head.packetParseData
			name = parser['name']
			read = parser['read']

			[parsedData[name], index] = read(buffer, index)

		packet = @packetCollection[@packetConditions[parsedData[@conditionField]]]

		if not packet?
			callback(null, null)

		for parser in packet.packetParseData
			name = parser['name']
			read = parser['read']

			[parsedData[name], index] = read(buffer, index)

		callback(packet.name, parsedData)

	setialize: (data, packetName, callback) ->
		packet = @packetCollection[packetName]
		bufferArray = []

		for parser in packet.packetParseData
			name = parser['name']
			write = parser['write']

			return new Buffer() if not data[name] # data not set, return empty buffer

			bufferArray.push(write(data[name]))

		callback(Buffer.concat(bufferArray)) # glue up whole array of buffers