FileLoader = require '../fileLoader/FileLoader' # get the fileloader
Async = require 'async'

module.exports = class Services

  constructor: (@config) ->
    @adapter = null # give adapter place in object
    @modelsFolder = 'application/models/'

  install: (callback) =>
    Injector.addService('$connect', @) # add connections to injector

    Async.series([
      (asyncCallback) => # database setup
        adapterModuleName = @config.get('adapter')

        if adapterModuleName?
          @adapterModule = require(adapterModuleName) # save the adapter module in services
          adapterOptions = @config.get(adapterModuleName) # get inject options
          adapterArgs = Injector.resolve(@adapterModule, adapterOptions)

          @adapter = new @adapterModule(adapterArgs...)

          @adapter.authenticate().done (err, result) ->
            if err?
              console.log err
            else
              console.log 'Database authentication successfull ...'

            global.Database = @adapter # give it global meaning

            asyncCallback(null, 1)
        else
          asyncCallback(null, 1)

      (asyncCallback) => # cache setup
        asyncCallback(null, 2)

      (asyncCallback) => # models setup
        loader = new FileLoader()

        loader.find @modelsFolder, (files) => # get the files
          if files? # if no files found in model folder, just skip
            for moduleName in files
              module = require(@modelsFolder + moduleName)

              @addModel moduleName, module

          # this also applies to no config
          sync = @config.get 'sync' # database synchronization
          if sync? and sync isnt false
            console.log "Syncing database"
            syncOptions = {}

            if @config.get('sync') is 'force'
                syncOptions.force = true

            @adapter.sync(syncOptions).done (err, result) ->
              console.log err if err
              console.log 'Services initialized'
              asyncCallback(null, 3)
          else
            asyncCallback(null, 3) # skip the 

    ], () ->
      callback(null, 2)
    )

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