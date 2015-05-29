Include = require("include-all")
Async = require("async")
Waterline = require("waterline") # orm/odm support

###
  Class that encapsulates logic for services including model services

  @author Gelidus
  @version 0.0.3a
###
module.exports = class Services

  ###
  @param config [Configuration] current configuration for service manager

  @example Configuration for Service manager (configs/connections.coffee)
    module.exports.connections = {
      disk: {
        adapter: "sails-disk"
      }
    }
  ###
  constructor: () ->
    # store the main(first) service if no service is defined within $connect.model call
    @mainService = null
    @objectMapper = new Waterline # initialize waterline
    @models = { }

  initialize: (options, callback) =>
    options.defaults.migrate = options.defaults.migrate || "alter"

    # normalize all adapters
    for adapterName, adapter of options.adapters
      adapter.identity = adapter.identity || adapterName # set identity

    for modelName, model of @models
      # normalize model options
      model.identity = model.identity || modelName
      model.connection = model.connection || options.defaults.connection

      collection = Waterline.Collection.extend(model)
      @objectMapper.loadCollection(collection)

    @objectMapper.initialize(options, callback)

  # Installs the service manager and adds the newly created instance to Injector as $connect
  # @param callback [Function] function to be called when install is finished
  install: (@connectionsConfig, @modelsConfig, callback, modelsFolder = "#{global.CurrentWorkingDirectory}/models/") =>

    services = @connectionsConfig.data.connections
    defaults = @modelsConfig.data.models

    waterlineOptions = {
      adapters: {}
      connections: {}
      collections: {}
      defaults: {}
    }

    Async.series [
      (asyncCallback) =>
        ###
          Loads model configuration file that will set default adapter
          and migration information
        ###
        for def, value of defaults
          waterlineOptions.defaults[def] = value

        asyncCallback(null, 1)

      (asyncCallback) =>
        ###
          Loads all adapters and connection information from connections
          configuration file
        ###
        for serviceName, options of services
          if not waterlineOptions.adapters[options.adapter]? # do not rewrite same modules
            waterlineOptions.adapters[options.adapter] = require(options.adapter) # feed adapter

          waterlineOptions.connections[serviceName] = options # save connection information

        asyncCallback(null, 2)

      (asyncCallback) =>
        ###
          Loads models information from models folder and adds them into collections
          information for waterlineOptions
        ###
        models = Include({
          dirname: modelsFolder
          filter: /(.*)(Model|Entity)\.(coffee|js)/
          excludeDirs: /^\.(git|svn)$/
        })

        for name, model of models
          @model(name, model)

        asyncCallback(null, 3)

      (asyncCallback) =>
        ###
          Initialize waterline and add it to services
        ###
        @initialize waterlineOptions, (err, ontology) =>
          Injector.addService("ObjectMapper", ontology)

          # inject created models
          for modelName, model of @models
            Injector.addService(modelName, ontology.collections[modelName.toLowerCase()])

          asyncCallback(err, 4)

    ], (err) ->
      callback(err)

  ###
    Adds model to previously defined service

    @param name [String] Name of model (for injector)
    @param modelOptions [Object] Map of options
    @param service [String] Name of service to bind model to
    @return model [Object] Created model

    @example Add model to previously created service @see service ( using previously injected $connect)
      $connect.model('MyModel', {
        tableName: 'my_model'
        attributes: {
          my_attribute: 'string'
          my_string: 'integer'
          ext_attribute: {
            type: 'string'
            size: 8 # string of size 8
          }
        }
      }, 'Database')
  ###
  model: (name, modelOptions) =>
    if not @objectMapper?
      throw new Error("No ObjectMapper was defined")

    @models[name] = modelOptions

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
