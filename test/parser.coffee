require "should"
Parser = require "../parser/Parser"
Packet = require "../parser/Packet"

describe "Packet", () ->

	###
	Basic tests
	###

	packetHead = null
	packet = null # non initialized packet
	describe "Packet construction", () ->

		it "should correctly construct packet with name", () ->
			packetHead = new Packet("head")
			packetHead.name.should.be.eql("head")
			packetHead.packetParseData.should.be.eql([])

			packet = new Packet("name")
			packet.name.should.be.eql("name")
			packet.packetParseData.should.be.eql([])

		it "should add uint8 to the packet parser and serialization", () ->
			packetHead.addUInt8("opcode")

			packetHead.packetParseData[0].should.be.ok
			packetHead.packetParseData[0].name.should.be.eql("opcode")

			packet.addUInt8("data")

			packet.packetParseData[0].should.be.ok
			packet.packetParseData[0].name.should.be.eql("data")

			packet.addStringLE("string")

			packet.packetParseData[1].should.be.ok
			packet.packetParseData[1].name.should.be.eql("string")

	parser = null # non initialized parser
	describe "Parser construction", () ->

		it "should correctly construct parser", () ->
			parser = new Parser(true) # is server parser

			parser.getHead().packetParseData.should.be.eql([])

			parser.setHead(packetHead) # set head to the opcode packet
			parser.getHead().should.be.eql(packetHead)

			parser.registerPacket(packet, false, 0)
			Object.keys(parser.clientPackets).length.should.be.eql(1)

			parser.registerPacket(packet, true)
			Object.keys(parser.serverPackets).length.should.be.eql(1)

		it "should serialize and parse packet", (done) ->
			parser.serialize {
				opcode: 0
				data: 5
				string: "abc"
			}, "name", (serialized) ->

				parser.parse serialized, (name, data) ->
					"name".should.be.eql(name)
					data["string"].should.be.eql("abc")
					data["data"].should.be.eql(5)
					done()

	describe "Advanced tests of packet and parser", () ->
		it "should add packet with array into the parser", () ->
			arrayPacketOne = new Packet("arrayone")
			arrayPacketTwo = new Packet("arraytwo")

			arrayPacketOne.addUInt8Array("numbers", 4)
			arrayPacketOne.packetParseData[0].name.should.be.eql("numbers")

			arrayPacketTwo.addUInt8Array("numbers", 6)
			arrayPacketTwo.packetParseData[0].name.should.be.eql("numbers")