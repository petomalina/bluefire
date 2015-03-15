global.CurrentWorkingDirectory = process.cwd() # set current dit to global for easy pathing

DependencyInjector = require("./di/Injector")

Async = require("async")
Configuration = require("./config").Configuration
ConfigurationManager = require("./config").ConfigurationManager

Services = require("./services/Services")
TaskManager = require("./task/TaskManager")
PolicyManager = require("./policies/PolicyManager")
Connection = require("./connection/Connection")

###
  Base Bluefire module. When install is called, application will try to load
  various files from folders (see documentation). This will enable structured
  approach to application style.
###
module.exports = class Application extends Connection

  ###
    Creates just basic applicatin with parser and tcp setup
    
    @param options [Object] an object of options
  ###
  constructor: (options = { }) ->
    options.isServer = if options.isServer is null then true else options.isServer
    options.configurations = options.configurations || "#{global.CurrentWorkingDirectory}/configs/"
    
    global.Injector = new DependencyInjector #establish injector
    @configurations = new ConfigurationManager(options.configurations)

    super(options.isServer) # creates defualt parser and injects server

    @taskManager = new TaskManager()
    # add task manager to the injector services
    Injector.addService("$taskmgr", @taskManager)

    @policyManager = new PolicyManager()
    Injector.addService("$policies", @policyManager)

    @services = new Services()
    Injector.addService("$service", @services) # add connections to injector

  ###
    Installs the whole application using structured approach

    @param callback [Function] function to be called after install
  ###
  install: (callback) =>
    if @configurations.get("config").get("environment") is "dev"
      global.debug = (debugText) ->
        console.log debugText
    else
      global.debug = () ->
        # nothing here

    Async.series([
      (asyncCallback) =>
        @configurations.load (err) ->
          asyncCallback(err, 1)
      
      (asyncCallback) =>
        @taskManager.install (err) ->
          asyncCallback(err, 2)

      (asyncCallback) =>
        @policyManager.install (err) ->
          asyncCallback(err, 3)

      (asyncCallback) =>
        @services.install @configurations.get("connections"), @configurations.get("models"), (err) ->
          asyncCallback(err, 4)

      (asyncCallback) =>
        super @configurations.get("config"), @configurations.get("routes"), (err) -> # call server install
          asyncCallback(err, 5)
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
    # virtual method - override this when needed

  _onDisconnect: (session) ->
    console.log "Client disconnected"
    session.removeAllTasks() # remove all current tasks on the session
    #@onDisconnect(session)

  onDisconnect: (session) =>
    # virtual method - override this when needed

  _onData: (session, packetName, data) =>
    @onData(session, packetName, data)

  ###
    @virtual
  ###
  onData: (session, packetName, data) =>
    # virtual method - override this when needed