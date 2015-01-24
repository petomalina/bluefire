
try
  Session = require '#{CurrentWorkingDirectory}/sessions/Session'
catch exception
  Session = class


###

@method #beforeSerialize
  Called before packet send
  @param [String] name of the packet
  @param [Object] data to be sent

@method #beforeSend
  Called before sending packet (after #beforeSerialize)
  @param [String] name of the packet
  @param [Object] non-serialized data
  @param [Byte Array] serialized data

@method #afterSend
  Called after sending packet (after #beforeSend)
  @param [String] name of the packet
  @param [Byte Array] serialized data 
###
module.exports = class ClientSession extends Session

  constructor: (socket, @parser) ->
    @socket = socket
    @tasks = { }

    socket.session = @
    socket.getSession = () =>
      return @session

  getSocket: () =>
    return @socket

  ###
  @private
  ###
  beforeSerialize: (packetName, data) ->

  ###
  @private
  ###
  beforeSend: (packetName, data, serialized) ->

  ###
  @private
  ###
  afterSend: (packetName, data) ->

  send: (packetName, data = { }, callback) =>
    @beforeSerialize packetName, data if @beforeSerialize?

    @parser.serialize data, packetName, (serialized) =>
      @beforeSend packetName, data, serialized if @beforeSend? # send non serialized and serialized data

      Injector.getService('$protocol').send(serialized, @)
      #@write(serialized)

      @afterSend packetName, data if @afterSend?
      callback() if callback?

  write: (data) =>
    @socket.write data

  addTask: (name) =>
    if @tasks[name]?
      @removeTask(name)

    @tasks[name] = Injector.getService('$taskmgr').perform('Ping', @)

  removeTask: (name) =>
    if @tasks[name]?
      console.log "Removing task #{name}"
      @tasks[name].stop()

    delete @tasks[name]

  removeAllTasks: () =>
    for name, task of @tasks
      @removeTask(name)