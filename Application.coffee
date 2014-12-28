global.Injector = require './di/Injector' # establish injector
require './BuddyObject' # require here for global definition

Async = require 'async'
Configuration = require './config/Configuration'

Services = require './services/Services'
Router = require './routing/Router'
TaskManager = require './task/TaskManager'
Server = require './server/Server'

###
Base Bluefire module. When install is called, application will try to load
various files from folders (see documentation). This will enable structured
approach to application style.
###
module.exports = class Application extends Server

  ###
  Creates just basic applicatin with parser and tcp setup
  ###
  constructor: () ->
    super # creates defualt parser and injects server

  ###
  Installs the whole application using structured approach

  @param callback [Function] function to be called after install
  ###
  install: (callback) =>

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

    Async.series([
      (asyncCallback) =>
        @taskManager = new TaskManager()
        @taskManager.install(asyncCallback)

      (asyncCallback) =>
        @services = new Services()
        @services.install(connectionConfiguration, asyncCallback)

      (asyncCallback) =>
        @router = new Router()
        @router.install(routesConfiguration, asyncCallback)

      (asyncCallback) =>
        super(globalConfiguration, asyncCallback) # call server install
    ], callback)

  ###
  Configurate the application. All currently injectable items will be injected
  into the callback function

  @param function [Function] injected callback for configuration

  @exmaple Configurate the application (application is already created Application instance)
    application.config ($connect, $router) ->
      # see documentation for injectable application modules to access API
  ###
  config: (callback) =>
    Injector.inject(callback, @)

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

  ###
  @virtual 
  ###
  onData: (session, packetName, data) =>
    # virtual method - override this when needed