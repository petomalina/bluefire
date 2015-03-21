
module.exports = class Protocol

  constructor: () ->

  ###
  Initializes session with the given data needed for protocol

  @param session [Session] a session to bind data to
  ###
  initializeSession: (session) ->
    # read means how many bytes we need to read from the stream to get full packet
    # traffic is packets per second
    # packets are already received packets
    session.protocol = { read: 0, traffic: 0, packets: [] }

  ###
    Gets length of protocol data for specified protocol
  ###
  length: (packets) ->
    len = 0
    for buffer in packets
      len += buffer.length

    return len

  ###
    Fetches given number of bytes from given protocol
    Will not control length before fetching
  ###
  fetch: (packets, length) ->
    buffer = new Buffer(length)
    currentIndex = 0

    loop
      packet = packets.splice(0, 1)[0]

      if packet.length is length - currentIndex # exact size
        packet.copy(buffer, currentIndex)
        break
      else if packet.length < length - currentIndex
        packet.copy(buffer, currentIndex)
        currentIndex += packet.length
      else # packet.length > length - currentIndex
        packet.copy(buffer, currentIndex, 0, length - currentIndex)
        rest = packet.slice(length - currentIndex)
        currentIndex += length - currentIndex
        packets.unshift(rest)
        break;

    return buffer

  ###
  Writes buffer data and protocol data to the socket stream

  @param buffer [Buffer] a buffer that will be sent
  @param session [Session] a session to send into
  ###
  send: (buffer, session) ->
    lengthBuffer = new Buffer(4) # first 4 bytes are always length
    lengthBuffer.writeUInt32LE(buffer.length, 0)

    if typeof buffer is "string" then buffer = new Buffer(buffer)

    session.write(Buffer.concat([lengthBuffer, buffer]))
    session.protocol.traffic++

  ###
  Receives the data from the session and parses the protocol data

  @param newBuffer [Buffer] a buffer that was received by socket
  @param session [Session] a session that received data
  @return [Buffer|null] returns Buffer if protocol was followed, else null
  ###
  receive: (newBuffer, session, callback) =>
    protocol = session.protocol
    protocol.packets.push(newBuffer) if newBuffer?

    if protocol.read is 0 and @length(protocol.packets) > 4
      buffer = @fetch(protocol.packets, 4)
      protocol.read = buffer.readUInt32LE(0)

    if protocol.read isnt 0 and @length(protocol.packets) >= protocol.read
      buffer = @fetch(protocol.packets, protocol.read)

      protocol.read = 0
      protocol.traffic++

      callback(buffer) if callback?
      @receive(null, session, callback) # recursive call