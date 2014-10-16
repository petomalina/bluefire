
module.exports = class ClientSession

  constructor: (socket) ->
    @socket = socket

    socket.session = @
    socket.getSession = () =>
      return @session

  getSocket: () =>
    return @socket

  send: (packetName, data, callback) =>
    Application.parser.serialize data, packetName, (serialized) =>
      @socket.write(serialized)

      callback() if callback?