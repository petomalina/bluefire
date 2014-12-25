###
Class of application Injector. Contains services and factories. May
containt service without factory (eg. application core items)

@note This class is inspired by angular dependency injection system
###
class Injector

  ###
  Initializes both, factories and services maps.
  ###
  constructor: () -> 
    @factories = { }
    @services = { }

  ###
  Adds Factory to the factory map

  @note This will not create service (lazy loading)
  ###
  addFactory: (key, factory) ->
    @factories[key] = factory

  ###
  Adds Service to the services map

  @note This does not affect any factories. Setting different service
  with same name as one of factories will prevent factory from creating
  correct service
  ###
  addService: (key, service) ->
    @services[key] = service

  # @param key[string] service name
  # @return service[Object] found service
  getService: (key) ->
    service = @services[key]

    if not service?
      factory = @factories[key]
      if not factory?
        return null

      service = factory()
      @services[key] = service

    return service

  # @param Constructor[function] class to create instance of
  # @return instance[Object] created object
  #
  # Creates new instance with injected constructor
  create: (Constructor) ->
    dependant = () ->
    dependant.prototype = Constructor.prototype

    instance = new dependant()
    @inject(Constructor, instance)

    return instance

  # @param Constructor[function] function to inject
  # @param instance[Object] object to apply injected function to
  inject: (Constructor, instance) ->
    deps = @resolve Constructor

    Constructor.apply instance, deps

  # @param func[function] funcion to resolve parameters on
  # @param dependencyList[Object] previously defined dependency list
  #         if no dependency list is defined, Injector will be used instead
  # @return dependencies[Array] ordered list of dependencies
  resolve: (func, dependencyList = null) ->
    keys = @getArguments func
    dependencies = []

    if dependencyList?
      dependencies.push(dependencyList[key]) for key in keys
    else
      dependencies = keys.map(@getService, @)

    return dependencies

  # @param func[function] function to get arguments from
  # @return args[Array] ordered list of arguments to function
  getArguments: (func) ->
    functionArgs = /^function\s*[^\(]*\(\s*([^\)]*)\)/m
    args = func.toString().match(functionArgs)[1].split(',')

    trueArgs = []
    for i in [0..args.length-1] # trim blanks here
      arg = args[i].trim()
      trueArgs.push arg if arg isnt ''

    return trueArgs

module.exports = new Injector()