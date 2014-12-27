
module.exports = class Router

  constructor: (configuration) ->
    @paths = { }
    @controllers = { }
    @configuration = configuration

    Injector.addService('$router', @)

  install: (callback) ->
    if @configuration.data.length > 1 # cont initialize paths if no paths are in data
      console.log 'Initializing paths ...'
      for code, path of @configuration.data
        @route code, path.controller, path.action,

      console.log 'Initializing needed controllers ...'
      for code, path of @paths
        if @controllers[path.controller]?
          continue # this controller already exists

        # add controller - require and load
        controller = require 'application/controllers/' + path.controller

        @controllers[path.controller] = Injector.create controller
        console.log "New controller registered: [#{path.controller}]"

    callback(null, 3)

  ###
  Creates new controller for the router

  @param name [String] name of the controller to by stored by
  @param module [Object] options for module
  @option options [String] name of module with the controller class
  @option options [Object] controller class

  @example Creating new controller (assume application/myControllers/controller already exists) 
    $router.controller('myController', 'application/myControllers/controller')
  ###
  controller: (name, module) ->
    if typeof(module) is 'object' # accept object as a controller
      @controllers[name] = module
    else
      @controllers[name] = require module

  ###
  Adds the route by the opcode, controllers name and its action name

  @param code [Object] opcode to handle the route by
  @param controlelr [String] name of controller to bind action to
  @param action [String] name of action for the controller
  ###
  route: (code, controller, action) ->
    @paths[code] = { action: action, controller: controller }
    console.log 'New route registered: [' + controller + ']->' + action

  call: (code, session, data) =>

    if @paths[code]?
      path = @paths[code]

      controller = @controllers[path.controller] # get controller by given path

      if not controller?
        path.action(session, data)
      else
        controller[path.action](session, data)

  getController: (name) ->
    return @controllers[name]