
module.exports = class Protocol

  constructor: () ->

  ###
  Initializes session with the given data needed for protocol

  @param session [Session] a session to bind data to
  ###
  initializeSession: (session) ->
    # properties for protocol
    # read means how many bytes we need to read from the stream to get full packet
    # write means how many bytes we have in queue
    # traffic is packets per second
    # loadBuffer is buffer that stores partial reads
    # bufferLoader is the current index of the load in the loadBuffer
    session.protocol = { read: 0, write: 0, traffic: 0, loadBuffer: null, bufferLoader: 0 }

  ###
  Writes buffer data and protocol data to the socket stream

  @param buffer [Buffer] a buffer that will be sent
  @param session [Session] a session to send into
  ###
  send: (buffer, session) ->
    lengthBuffer = new Buffer(4) # first 4 bytes are always length
    lengthBuffer.writeUInt32LE(buffer.length, 0)

    session.write(Buffer.concat([lengthBuffer, buffer]))
    session.protocol.traffic++

  ###
  Receives the data from the session and parses the protocol data

  @param data [Buffer] a buffer that was received by socket
  @param session [Session] a session that received data
  @return [Buffer|null] returns Buffer if protocol was followed, else null
  ###
  receive: (buffer, session, callback) =>
    protocol = session.protocol

    if protocol.read is 0 # receive new packet
      protocol.traffic++
      protocol.read = 0 # clear read property

      length = buffer.readUInt32LE(0)
      buffer = buffer.slice(4) # shift start index to the right

      if buffer.length is length # whole packet received
        callback(buffer) if callback?
        return
      else
        protocol.read = length # set bytes to read
        protocol.loadBuffer = new Buffer(length)
        protocol.bufferLoader = 0 # reset buffer loader

    if buffer.length is 0 # skip null packets (or just 4 bytes as length)
      return

    if buffer.length is protocol.read # we need to read the same ammount
      buffer.copy(protocol.loadBuffer, protocol.bufferLoader)
      protocol.read = 0 # reset read cause buffer is now ok

      callback(protocol.loadBuffer) if callback?
    else if buffer.length < protocol.read # not enough still
      buffer.copy(protocol.loadBuffer, protocol.bufferLoader)
      protocol.read -= buffer.length # decrement by buffer length (we need less now)
      protocol.bufferLoader += buffer.length # shift right

    else # buffer.length > protocol.read
      buffer.copy(protocol.loadBuffer, protocol.bufferLoader, 0, protocol.read)
      callback(protocol.loadBuffer)

      buffer = buffer.slice(protocol.read) # slice to the new buffer
      protocol.read = 0 # reset read to 0 as we need to do one more iteration and start again

      @receive(buffer, session, callback)