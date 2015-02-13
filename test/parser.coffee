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

      packet = new Packet("name", packetHead)
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
  
  describe "Parser construction", () ->
    parser = new Parser(true) # is server parser
    parser.initialize()

    it "should correctly construct parser", () ->
      parser.getHead().packetParseData.should.be.eql([])

      parser.setHead(packetHead) # set head to the opcode packet
      parser.getHead().should.be.eql(packetHead)

      parser.registerPacket(packet, false, 0)
      Object.keys(parser.clientPackets).length.should.be.eql(1)

      parser.registerPacket(packet, true, 0)
      Object.keys(parser.serverPackets).length.should.be.eql(1)

    it "should serialize and parse packet", (done) ->
      parser.serialize {
        data: 5
        string: "abc"
      }, "name", (serialized) ->
        parser.parse serialized, (name, data) ->
          "name".should.be.eql(name)
          data["string"].should.be.eql("abc")
          data["data"].should.be.eql(5)
          done()

  describe "Advanced tests of packet and parser", () ->
    parser = new Parser(true) # is server parser
    parser.initialize()

    it "should set the parser head", () ->
      parser.getHead().packetParseData.should.be.eql([])
      parser.setHead(packetHead)
      parser.getHead().packetParseData.length.should.be.eql(1)

    it "should add packet with array into the parser", (done) ->
      arrayPacketOne = new Packet("arrayone", packetHead)
      arrayPacketTwo = new Packet("arraytwo", packetHead)

      arrayPacketOne.addUInt8Array("numbers", 4)
      arrayPacketOne.packetParseData[0].name.should.be.eql("numbers")

      arrayPacketTwo.addUInt8Array("numbers", 6)
      arrayPacketTwo.packetParseData[0].name.should.be.eql("numbers")

      parser.registerPacket(arrayPacketOne, false, 0)
      parser.registerPacket(arrayPacketOne, true, 0)
      parser.registerPacket(arrayPacketTwo, false, 1)
      parser.registerPacket(arrayPacketTwo, true, 1)

      (parser.getPacket("arrayone")?).should.be.true # existence check

      parser.serialize {
        #opcode: 0
        numbers: [1, 2, 3, 4]
      }, "arrayone", (serialized) ->
        parser.parse serialized, (name, data) ->
          (data?).should.be.true
          data.opcode.should.be.eql(0)
          data.numbers.should.be.eql([1,2,3,4])
          done()

    it "should try to serialize and parse second array packet", (done) ->

      parser.serialize {
        #opcode: 1
        numbers: [9, 2, 1, 4, 3, 6]
      }, "arraytwo", (serialized) ->
        done()

  describe "Advanced #add() method packet tests", () ->

    it "should add structure to the packet with #add() method", () ->
      parser = new Parser(true)
      parser.initialize()

      parser.setHead(packetHead)
      firstPacket = new Packet("firstPacket", packetHead)

      firstPacket.add [
        something: 'uint8'
      , int: 'int32le'
      ]

      firstPacket.packetParseData.length.should.be.eql(2)
      firstPacket.predefinedValues.should.be.eql({})

      firstPacket.add [
        opcode: 0
      ]

      (firstPacket.predefinedValues["opcode"]?).should.be.true
      firstPacket.predefinedValues["opcode"].should.be.eql(0)
      firstPacket.packetParseData.length.should.be.eql(2)

    it "should correctly parse and serialize advanced packet", (done) ->
      parser = new Parser(true)
      parser.initialize()

      parser.setHead(packetHead)

      firstPacket = new Packet("firstPacket", packetHead)

      firstPacket.add [
        opcode: 0
      , something: 'uint8'
      , int: 'int32le'
      ]

      parser.registerPacket(firstPacket, false, 0) # client packet
      parser.registerPacket(firstPacket, true, 0) # server packet

      parser.serialize {
        something: 12
        int: 1800
      }, "firstPacket", (serialized) ->
        parser.parse serialized, (name, data) ->
          (data?).should.be.true
          data["opcode"].should.be.eql(0)
          data["something"].should.be.eql(12)
          data["int"].should.be.eql(1800)
          done()