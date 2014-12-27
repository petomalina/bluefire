module.exports = class Parser

	constructor: (@conditionField = 'opcode') ->

	registerHead: () ->

	getHead: () ->

	setConditionField:(@conditionField) ->

	registerPacket: (packetName, condition = null) ->

	getPacket: (packetName) ->

	registerondition: (packetName, condition) ->