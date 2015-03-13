require "should"
Protocol = require "../connection/Protocol"

# mock object for session
mockSession = {
  lastData: null

  write: (@lastData) ->
}

describe "Protocol", () ->

  describe "#constructor()", () ->
    it "should correctly construct protocol", () ->
      protocol = new Protocol()

    it "should initialize initialize mock session for protocol", () ->
      protocol = new Protocol()
      protocol.initializeSession(mockSession)

  describe "#send()", () ->
    it "should send data to the given socket", () ->
      protocol = new Protocol()

      buffer = new Buffer(5)
      buffer.writeUInt8(2, 0)
      buffer.writeUInt32LE(18950, 1)

      protocol.send(buffer, mockSession)

      (mockSession.lastData?).should.be.true
      mockSession.lastData.length.should.be.eql(9)

  describe "#length()", () ->
    it "should correctly calculate length of protocol packets", () ->
      protocol = new Protocol

      packets = [new Buffer(4), new Buffer(7)]

      protocol.length(packets).should.be.eql(11)

  describe "#fetch()", () ->
    it "should be able to fetch exact data from protocol", () ->
      protocol = new Protocol

      packets = [new Buffer("Hello")]

      fetch = protocol.fetch(packets, 5)
      fetch.length.should.be.eql(5)
      fetch.toString().should.be.eql("Hello")

    it "should be able to fetch part of data from protocol", () ->
      protocol = new Protocol

      packets = [new Buffer("Hello")]

      fetch = protocol.fetch(packets, 3)
      fetch.length.should.be.eql(3)
      fetch.toString().should.be.eql("Hel")
      packets[0].toString().should.be.eql("lo")

    it "should be able to fetch from two parts (exact size)", () ->
      protocol = new Protocol

      packets = [new Buffer("Hello"), new Buffer("World")]

      fetch = protocol.fetch(packets, 10)
      fetch.length.should.be.eql(10)
      fetch.toString().should.be.eql("HelloWorld")
      packets.length.should.be.eql(0)

    it "should fetch data from parts and leave rest", () ->
      protocol = new Protocol

      packets = [new Buffer("Hello"), new Buffer("World"), new Buffer("rest")]

      fetch = protocol.fetch(packets, 10)
      fetch.length.should.be.eql(10)
      fetch.toString().should.be.eql("HelloWorld")
      packets.length.should.be.eql(1)
      packets[0].toString().should.be.eql("rest")

  describe "#receive()", () ->
    it "should receive data from the socket (full sized)", (done) ->
      protocol = new Protocol()

      protocol.receive mockSession.lastData, mockSession, (buffer) ->
        (buffer?).should.be.true # should be ok with receiving full packet
        done()

    it "should receive more packets and build one from it", (done) ->
      protocol = new Protocol()

      firstCut = new Buffer(6)
      secondCut = new Buffer(3)

      mockSession.lastData.copy(firstCut, 0, 0, 6)
      mockSession.lastData.copy(secondCut, 0, 6)

      firstCut.length.should.be.eql(6)
      secondCut.length.should.be.eql(3)

      protocol.receive firstCut, mockSession

      protocol.receive secondCut, mockSession, (received) ->
        (received?).should.be.true

        concated = Buffer.concat([firstCut, secondCut])
        concated = concated.slice(4) # slice the length as it is removed in receive

        for i in [0...received.length]
          received[i].should.be.eql(concated[i])

        mockSession.protocol.read.should.be.eql(0)

        done()

    it "should correctly receive two packets that are glued together", (done) ->
      protocol = new Protocol()
      protocol.initializeSession(mockSession)

      buffer = new Buffer(20)
      buffer.writeUInt32LE(6, 0)
      buffer.writeUInt32LE(800, 4)
      buffer.writeUInt16LE(128, 8)

      buffer.writeUInt32LE(6, 10)
      buffer.writeUInt32LE(800, 14)
      buffer.writeUInt16LE(128, 18)

      counter = 0

      protocol.receive buffer, mockSession, (buffer) ->
        (buffer?).should.be.true
        buffer.length.should.be.eql(6)

        buffer.readUInt32LE(0).should.be.eql(800)
        buffer.readUInt16LE(4).should.be.eql(128)

        counter++
        if counter is 2
          mockSession.protocol.read.should.be.eql(0)
          done()

    it "should correcty receive two heavy fragmented packets", (done) ->
      protocol = new Protocol()
      protocol.initializeSession(mockSession)

      buffer = new Buffer(20)
      buffer.writeUInt32LE(6, 0)
      buffer.writeUInt32LE(800, 4)
      buffer.writeUInt16LE(128, 8)

      buffer.writeUInt32LE(6, 10)
      buffer.writeUInt32LE(1800, 14)
      buffer.writeUInt16LE(5, 18)

      protocol.receive buffer.slice(0, 5), mockSession, (buffer) ->
        throw new error("Missing parts of buffer")

      protocol.receive buffer.slice(5, 9), mockSession, (buffer) ->
        throw new error("Missing parts of buffer")

      protocol.receive buffer.slice(9, 15), mockSession, (buffer) ->
        (buffer?).should.be.true
        buffer.readUInt32LE(0).should.be.eql(800)
        buffer.readUInt16LE(4).should.be.eql(128)

      protocol.receive buffer.slice(15, 19), mockSession, (buffer) ->
        throw new error("Missing parts of buffer")

      protocol.receive buffer.slice(19), mockSession, (buffer) ->
        (buffer?).should.be.true
        buffer.readUInt32LE(0).should.be.eql(1800)
        buffer.readUInt16LE(4).should.be.eql(5)

      done()

    it "should correctly receive two heavy fragmented lengths of packets", (done) ->
      protocol = new Protocol
      protocol.initializeSession(mockSession)

      buffer = new Buffer(20)
      buffer.writeUInt32LE(6, 0)
      buffer.writeUInt32LE(800, 4)
      buffer.writeUInt16LE(128, 8)

      buffer.writeUInt32LE(6, 10)
      buffer.writeUInt32LE(1800, 14)
      buffer.writeUInt16LE(5, 18)

      protocol.receive buffer.slice(0, 2), mockSession, (buffer) ->
        throw new error("Missing parts of buffer")

      protocol.receive buffer.slice(2, 5), mockSession, (buffer) ->
        throw new error("Missing parts of buffer")

      protocol.receive buffer.slice(5, 10), mockSession, (buffer) ->
        (buffer?).should.be.true
        buffer.readUInt32LE(0).should.be.eql(800)
        buffer.readUInt16LE(4).should.be.eql(128)

      protocol.receive buffer.slice(10), mockSession, (buffer) ->
        (buffer?).should.be.true
        buffer.readUInt32LE(0).should.be.eql(1800)
        buffer.readUInt16LE(4).should.be.eql(5)