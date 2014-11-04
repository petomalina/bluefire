
try
  Session = require 'application/sessions/Session'
catch exception
  Session = class

module.exports = class ClientSession extends Session

  constructor: (socket) ->
    @socket = socket
    @tasks = { }

    socket.session = @
    socket.getSession = () =>
      return @session

  getSocket: () =>
    return @socket

  send: (packetName, data = { }, callback) =>
    @beforeSerialize packetName, data if @beforeSerialize?

    Application.parser.serialize data, packetName, (serialized) =>
      @beforeSend packetName, data, serialized if @beforeSend? # send non serialized and serialized data

      @socket.write(serialized)

      @afterSend packetName, data if @afterSend?
      callback() if callback?

  write: (data) =>
    @socket.write data

  addTask: (name) =>
    if @tasks[name]?
      @removeTask(name)

    @tasks[name] = Injector.get('$TaskManager').perform('Ping', @)

  removeTask: (name) =>
    if @tasks[name]?
      console.log "Removing task #{name}"
      @tasks[name].stop()

    delete @tasks[name]

  removeAllTasks: () =>
    for name, task of @tasks
      @removeTask(name)