global.Injector = require './di/Injector' # establish injector
require './BuddyObject' # require here for global definition

Async = require 'async'
Configuration = require './config/Configuration'

Services = require './services/Services'
Router = require './routing/Router'
TaskManager = require './task/TaskManager'
Server = require './server/Server'

module.exports = class Application extends Server

  constructor: (callback) ->
    global.Application = @
    Injector.addService('$app', @) # add this object to injector

    connectionConfiguration = new Configuration()
    connectionConfiguration.load 'application/configs/connections'

    routesConfiguration = new Configuration()
    routesConfiguration.load 'application/configs/routes'

    globalConfiguration = new Configuration() # global configuration
    globalConfiguration.load 'application/configs/config'

    if globalConfiguration.get "configuration" is "debug"
      global.debug = (debugText) ->
        console.log debugText
    else
      global.debug = () ->
        # nothing here

    super(globalConfiguration) # initialize server beneath the application

    Async.series([
      (callback) =>
        @taskManager = new TaskManager()
        @taskManager.install(callback)

      (callback) =>
        @services = new Services(connectionConfiguration)
        @services.install(callback)

      (callback) =>
        @router = new Router(routesConfiguration)
        @router.install(callback)

      (callback) =>
        @install(callback)
    ], callback)

  install: (callback) =>
    super callback # install the server

  config: (callback) =>
    Injector.inject(callback, @)

  # @param code[opcode] operation code to bind to
  # @param action[string] action name of controller
  # @param controller[string] controller name
  # adds specified route to the application router
  route: (code, action, controller) ->
    @router.route code, action, controller

  # adds specified controller into the router
  controller: (name, controller) ->
    @router.controller name, controller

  getController: (name) ->
    @router.getController(name)

  run: () ->
    super # run the server

  onConnect: (session) ->
    console.log 'connect'
    # virtual method - override this when needed

  _onDisconnect: (session) ->
    console.log 'Client disconnected'
    session.removeAllTasks() # remove all current tasks on the session
    #@onDisconnect(session)

  onDisconnect: (session) =>
    # virtual method - override this when needed

  _onData: (session, packetName, data) =>
    @router.call packetName, session, data
    @onData(session, packetName, data)

  onData: (session, packetName, data) =>
    # virtual method - override this when needed