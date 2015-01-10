FileLoader = require '../fileLoader/FileLoader' # get the fileloader
Async = require 'async'

module.exports = class Services

  ###
  @param config [Configuration] current configuration for service manager
  
  @example Configuration for Service manager (configs/connections.coffee)
    module.exports = {
      Database: { # service name
        module: 'sequelize' # module name of service
        arguments: { # arguments to be passed to the service constructor
          database: 'my_database'
          username: 'root'
          password: '1234'

          options: {
            dialest: 'postgres'
            port: 5432
          }
        }

        # optional callbacks
        beforeCreate: (options, moduleArgs) ->

        afterCreate: (service) ->
         service.authenticate().complete(err) -> # authenticate sequelize
           console.log err if err?
      }
    }
  ###
  constructor: () ->
    #@adapter = null # give adapter place in object
    @modelsFolder = "#{global.CurrentWorkingDirectory}/models/"

    # store the main(first) service if no service is defined within $connect.model call
    @mainService = null

  # Installs the service manager and adds the newly created instance to Injector as $connect
  # @param callback [Function] function to be called when install is finished
  install: (@config, callback) =>

    Async.series([
      (asyncCallback) => # database setup
        services = @config.data

        for serviceName, options of services
          # service class
          ServiceModule = require(options.module)
          # get service options
          serviceArguments = options.arguments
          # resolve service constructor
          serviceConstructArguments = Injector.resolve(ServiceModule, serviceArguments)
          # create service
          service = new ServiceModule(serviceConstructArguments...)

          # add service to injector
          Injector.addService(serviceName, service)

          if @mainService is null
            @mainService = service

        asyncCallback(null, 1)

      (asyncCallback) => # models setup
        loader = new FileLoader()

        loader.find @modelsFolder, (files) => # get the files
          for moduleName in files
            moduleName = moduleName.split('.')[0]

            module = require(@modelsFolder + moduleName)

            @model(moduleName, module.model, module.service)

          asyncCallback(null, 2)
    ], () ->
      callback(null, 2)
    )
  
  ###
  Adds model to previously defined service
  @param name [String] name of model (for injector)
  @param modelOptions [Object] map of options
  @param service [String] name of service to bind model to
  
  @example Add model to previously created service @see service ( using previously injected $connect)
    $connect.model('MyModel', {
      modelName: 'my_model'
      attributes: {
        my_attribute: 'INTEGER'
        my_string: 'STRING'
      }
    }, 'Database')
  ###
  model: (name, modelOptions, service = null) =>

    if service is null and @mainService isnt null
      service = @mainService
    else if service isnt null
      service = Injector.getService(service) # get service by name from injector
    
    if service is null # could not be found
      console.log "[Bluefire Services] Cannot attach model to non existing service"
      return

    definitionArguments = Injector.resolve(service.define, modelOptions)

    model = service.define(definitionArguments...) # splat arguments

    Injector.addService(name, model)

    console.log "New model registered: [#{name}]"

  ###
  Adds service to the service map. This method is synchronous.

  @param name [String] the name of service
  @param moduleName [String] name of module to be loaded
  @param options [Object] options passed to constructor of module
  @param beforeCreate [Function] callback called before construction of service
  @param afterCreate [Function] callback called after service construction
  @return [Object] newly created service

  @example Create database service with sequelize orm (previously injected $connect used)
    $connect.service('Database', 'sequelize', {
      database: 'my_database'
      username: 'root'
      password: '1234'
      options: {
        dialest: 'postgres'
        port: 5432
      }
    })
  ###
  service: (name, moduleName, options, beforeCreate, afterCreate) ->
    Module = require(moduleName)

    moduleArgs = Injector.resolve(Module, options)

    beforeCreate(options, moduleArgs) if beforeCreate? # callback the injected arguments

    service = new Module(moduleArgs...) # create service with args

    Injector.addService(name, service) # register service to injector

    afterCreate(service) if afterCreate? # callback created service

    return service