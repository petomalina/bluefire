FileLoader = require("../fileLoader/FileLoader") # get the fileloader
Async = require("async")

###
  Class that encapsulates logic for services including model services

  @author Gelidus
  @version 0.0.3a
###
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
    # store the main(first) service if no service is defined within $connect.model call
    @mainService = null

  # Installs the service manager and adds the newly created instance to Injector as $connect
  # @param callback [Function] function to be called when install is finished
  install: (@config, callback, modelsFolder = "#{global.CurrentWorkingDirectory}/models/") =>

    services = @config.data

    Async.series([
        (asyncCallback) =>
          if services.beforeAll?
            services.beforeAll (err) ->
              asyncCallback(err, 1)
          else
            asyncCallback(null, 1)

        (asyncCallback) => # database setup
          Async.eachSeries Object.keys(services), (serviceName, iterator) =>
            if serviceName is "beforeAll" or serviceName is "afterAll"
              iterator()
              return

            options = services[serviceName]
            @service serviceName, options.module, options.arguments, options.beforeCreate, (service) -> # wait for afterCreate here
              if options.afterCreate? then options.afterCreate(service, iterator) else iterator()
          , (err) ->
            asyncCallback(err, 2)

        (asyncCallback) => # models setup
          loader = new FileLoader()

          loader.find modelsFolder, (files) => # get the files
            for moduleName in files
              # skip modules that won't meet conditions
              continue if not /(\w+(Model|Entity))\..+/.test(moduleName)

              moduleName = moduleName.split('.')[0]

              module = require(modelsFolder + moduleName)

              @model(moduleName, module.model, module.service)

              console.log("New model registered: #{moduleName}")

            asyncCallback(null, 3)

        (asyncCallback) =>
          if services.afterAll?
            args = Injector.resolve(services.afterAll)
            if args[args.length-1]?
              services.afterAll(args...)
              asyncCallback(null, 4)
            else
              args.pop()
              args.push (err) -> # push to arguments as callback
                asyncCallback(err, 4)

              services.afterAll(args...)
          else
            asyncCallback(null, 4)
      ], () ->
      callback(null, 2)
    )

  ###
    Adds model to previously defined service

    @param name [String] Name of model (for injector)
    @param modelOptions [Object] Map of options
    @param service [String] Name of service to bind model to
    @param registerFunctionName [String] Name of function which should be used to register model in the service
    @return model [Object] Created model

    @example Add model to previously created service @see service ( using previously injected $connect)
      $connect.model('MyModel', {
        modelName: 'my_model'
        attributes: {
          my_attribute: 'INTEGER'
          my_string: 'STRING'
        }
      }, 'Database')
  ###
  model: (name, modelOptions, serviceName = null, registerFunctionName = "define") =>

    if serviceName is null and @mainService isnt null
      service = @mainService
    else if service isnt null
      service = Injector.getService(serviceName) # get service by name from injector

    if not service? # could not be found
      console.log "[Bluefire Services] Cannot attach model to non existing service #{serviceName}"
      return

    if @config?
      # calculation of true attributes from service model
      # this is now only for sequelize
      trueAttributes = { }
      serviceModule = require(@config.data[serviceName].module)
      for attribute, type of modelOptions.attributes
        if typeof type is "string"
          trueAttributes[attribute] = serviceModule[type]
        else
          trueAttributes[attribute] = type

    modelOptions.attributes = trueAttributes

    definitionArguments = Injector.resolve(service[registerFunctionName], modelOptions)

    model = service[registerFunctionName](definitionArguments...) # splat arguments

    Injector.addService(name, model)

    return model

  ###
    Adds service to the service map. This method is synchronous.

    @param name [String] the name of service
    @param module [String|Class] name of module to be loaded or it's class
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
  service: (name, module, options = { }, beforeCreate, afterCreate) ->
    Module = if typeof module is "string" then require(module) else module

    moduleArgs = Injector.resolve(Module, options)

    beforeCreate(options, moduleArgs) if beforeCreate? # callback the injected arguments

    service = new Module(moduleArgs...) # create service with args

    Injector.addService(name, service) # register service to injector

    if @mainService is null
      @mainService = service

    if afterCreate? # callback created service
      afterCreate service

    return service