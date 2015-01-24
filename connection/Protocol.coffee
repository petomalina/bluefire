
module.exports = class Protocol

  constructor: () ->

  ###
  Writes buffer data and protocol data to the socket stream

  @param buffer [Buffer] a buffer that will be sent
  @param session [Session] a session to send into
  ###
  send: (buffer, session) ->

  ###
  Receives the data from the session and parses the protocol data

  @param data [Buffer] a buffer that was received by socket
  @param session [Session] a session that received data
  ###
  receive: (buffer, session) ->