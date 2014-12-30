Packet = require('./Packet')

module.exports = class Parser

	constructor: (@conditionField = 'opcode', @isServer = true) ->
		@head = new Packet("Head") # register empty head

		@serverPackets = { }
		@clientPackets = { }
		@packetConditions = { } # condition - name map

	###
	@return [Packet] packet representing head for all packets
	###
	getHead: () =>
		return @head

	###
	Sets the condition field to the custom one

	@param conditionField[String] name of condition field in packet
	###
	setConditionField:(@conditionField) ->

	###
	Registers 
	###
	registerPacket: (packetName, isServerPacket, condition = null) =>
		packet = new Packet(packetName, @packetHead)

		if isServerPacket # switch between server and client packets
			@serverPackets[packetName] = packet
		else
			@clientPackets[packetName] = packet

		# register condition for current packet
		if (@isServer and not isServerPacket) or (not @isServer and isServerPacket)
			@registerCondition(packetName, condition)

		return packet

	###
	Returns packet from collection by given type

	@param packetName [String] packet name from collection
	@param isServer [Boolean] true if server packet is needed, else false. Default: true
	###
	getPacket: (packetName, isServer = true) ->
		return if isServer then @serverPackets[packetName] else @clientPackets[packetName]

	registerCondition: (packetName, condition = null) ->
		if condition? and packetName?
			@packetConditions[condition] = packetName 			

	###
	Parses the given data buffer into the structure which
	represents the given packet by conditionField from head

	@param data [Buffer] buffer to be parsed
	@param callback [Function] callback to be called after parse
	@param packetname [String] optional packet name if already known
	###
	parse: (data, callback, packetName = null) ->
		parsedData = { }
		head = @getHead()
		index = 0 # current byte index for parser

		# read whole head
		for parser in head.packetParseData
			name = parser['name']
			read = parser['read']

			[parsedData[name], index] = read(buffer, index)

		# parse packets that are oposite
		packet = @getPacket(@packetConditions[parsedData[@conditionField]], !@isServer)

		if not packet?
			callback(null, null)

		for parser in packet.packetParseData
			name = parser['name']
			read = parser['read']

			[parsedData[name], index] = read(buffer, index)

		callback(packet.name, parsedData)

	###
	Creates byte buffer that can be passed right into socket with current
	packet structure

	@param data [Object] data to be serialized
	@param packetName [String] name of packet to serialize
	@param callback [Function] function to be called

	@example Serialization of previously registered packet with name 'myPacket'
		serialize { myInt : 5}, 'myPacket', (buffer) ->
			#send buffer or do something else
	###
	setialize: (data, packetName, callback) ->
		# serialize packets from this side
		packet = @getPacket([packetName], @isServer)
		bufferArray = []

		for parser in packet.packetParseData
			name = parser['name']
			write = parser['write']

			return new Buffer() if not data[name] # data not set, return empty buffer

			bufferArray.push(write(data[name]))

		callback(Buffer.concat(bufferArray)) # glue up whole array of buffers