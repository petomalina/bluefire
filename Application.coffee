Async = require 'async'
global.Injector = require './di/injector' # establish injector
Configuration = require './config/configuration'

Services = require './services/services'
Router = require './routing/router'
Server = require './server/server'

module.exports = class Application extends Server

  constructor: (callback) ->
    global.Application = @

    connectionConfiguration = new Configuration()
    connectionConfiguration.load 'application/configs/connections'

    routesConfiguration = new Configuration()
    routesConfiguration.load 'application/configs/routes'

    globalConfiguration = new Configuration()
    globalConfiguration.load 'application/configs/config'

    super(globalConfiguration) # initialize server beneath the application

    Async.series([
      (callback) =>
        @services = new Services(connectionConfiguration)
        @services.install(callback)

      (callback) =>
        @router = new Router(routesConfiguration)
        @router.install(callback)

      (callback) =>
        @install(callback)
    ], callback)

  install: (callback) ->
    super callback # install the server

  # adds specified route to the application router
  route: (code, action, controller) ->
    @router.route code, action, controller

  # adds specified controller into the router
  controller: (name, controller) ->
    @router.controller name, controller

  run: () ->
    super # run the server

  onConnect: (session) =>
    # virtual method - override this when needed

  _onDisconnect: (session) =>
    @onDisconnect(session)

  onDisconnect: (session) =>
    # virtual method - override this when needed

  _onData: (session, packetName, data) =>
    @router.call packetName, session, data

    @onData(session, packetName, data)

  onData: (session, packetName, data) =>
    # virtual method - override this when needed