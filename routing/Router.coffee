
module.exports = class Router

  constructor: (configuration) ->
    @paths = { }
    @controllers = { }
    @configuration = configuration

  install: (callback) ->
    console.log 'Initializing paths ...'
    for code, path of @configuration.data
      @route code, path.action, path.controller

    console.log 'Initializing needed controllers ...'
    for code, path of @paths
      if @controllers[path.controller]?
        continue # this controller already exists

      # add controller - require and load
      controller = require 'application/controllers/' + path.controller

      @controllers[path.controller] = controller
      console.log 'New controller registered : [' + path.controller + ']'

    Injector.addService('$router', @)
    console.log 'Router initialized'
    callback(null, 1)

  controller: (name, module) ->
    if typeof(module) is 'object' # accept object as a controller
      @controllers[name] = module
    else
      @controllers[name] = require module

  route: (code, action, controller) ->
    @paths[code] = { action: action, controller: controller }
    console.log 'New route registered : [' + controller + ']->' + action

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