FileLoader = require '../fileLoader/FileLoader' # get the fileloader
Async = require 'async'

module.exports = class Services

  constructor: (@config) ->
    @adapterModule = require @config.get 'adapter' # save the adapter module in services
    @adapter = null # give adapter place in object
    @modelsFolder = 'application/models/'

  install: (callback) =>
    Async.series([
      (callback) => # database setup
        adapterOptions = @config.get(@config.get('adapter')) # get inject options
        adapterArgs = Injector.resolve @adapterModule, adapterOptions

        @adapter = new @adapterModule(adapterArgs...)

        @adapter.authenticate().done (err, result) ->
          if err?
            console.log err
          else
            console.log 'Database authentication successfull ...'

          global.Database = @adapter # give it global meaning

          callback(null, 1)

      (callback) => # cache setup
        callback(null, 2)

      (callback) => # models setup
        loader = new FileLoader()

        loader.find @modelsFolder, (files) => # get the files
          for moduleName in files
            module = require(@modelsFolder + moduleName)

            @addModel moduleName, module

          sync = @config.get 'sync' # database synchronization
          if sync? and sync isnt false
            console.log "Syncing database"
            syncOptions = {}

            if @config.get('sync') is 'force'
                syncOptions.force = true

            @adapter.sync(syncOptions).done (err, result) ->
              console.log err if err
              console.log 'Services initialized'
              callback(null, 3)
          else
            callback(null, 3) # skip the sync

    ], callback)

  addModel: (name, modelOptions) =>

    for attribute, type of modelOptions.attributes # set attributes to module specifig attributes
      modelOptions.attributes[attribute] = @adapterModule[modelOptions.attributes[attribute]]

    name = name.split('.')[0] # get the first word
    args = Injector.resolve @adapter.define, modelOptions

    Model = @adapter.define args...
    global[name] = Model # globalize model

    Injector.addService(name, Model)

    console.log "New model registered: [#{name}]"

  addDataService: (name, options) ->
    service = require name