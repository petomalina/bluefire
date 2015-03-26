Async = require("async")

###
Class that calls controllers and their actions that were previously loaded by
given packet and condition. This class stores names of server packets if client,
else client packets (those which are received).
This may also load the paths and after that, needed controllers.

@author Gelidus
@version 0.0.3a
###
module.exports = class Router

  constructor: () ->
    @paths = { }
    @controllers = { }

  install: (@configuration, callback, controllersFolder = "#{global.CurrentWorkingDirectory}/controllers/") ->
    if Object.keys(@configuration.data).length > 0 # cont initialize paths if no paths are in data
      for code, path of @configuration.data
        @route code, path.action, path.controller, path.policies

      for code, path of @paths
        if @controllers[path.controller]?
          continue # this controller already exists

        # add controller - require and load
        controller = require(controllersFolder + path.controller)

        @controllers[path.controller] = Injector.create controller

    callback(null, 3) if callback # only needed in async. This is synchronous

  ###
  Creates new controller for the router

  @param name [String] name of the controller to by stored by
  @param module [Object|Constructor] already constructed object or constructor that will be injected

  @example Creating new controller (all properties are injected inside constructor)
    $router.controller "myController", class MyController
      constructor: (MyModel) ->
  ###
  controller: (name, module) ->
    if typeof(module) is 'object' # accept object as a controller
      @controllers[name] = module
    else
      @controllers[name] = Injector.create(module)

  ###
  Adds the route by the opcode, controllers name and its action name

  @param packetName [Object] opcode to handle the route by
  @param controller [String] name of controller to bind action to
  @param action [String] name of action for the controller
  ###
  route: (packetName, action, controller = null, policies = []) ->
    policyManager = Injector.getService("$policies")

    @paths[packetName] = { action: action, controller: controller, policies: policyManager.get(policies) }

  call: (packetName, session, data) =>
    if @paths[packetName]?
      path = @paths[packetName]
      controller = @controllers[path.controller] # get controller by given path

      # check all policies here
      Async.each path.policies, (policy, next) ->
        policy.perform(session, data, next)
      , (err) ->
        # all policies were successfully "nexted"
        return if err? # something happened during policy checking

        if not controller? # support for non-controller functions
          path.action(session, data)
        else
          controller[path.action](session, data)

  getController: (name) ->
    return @controllers[name]