module.exports = {

  dependencies: { }

  register: (name, dependency) ->
    @dependencies[name] = dependency

  get: (name) ->
    return @dependencies[name]

  injectWithDependencies: (func, deps) ->
    object = new func
    args = @getArguments func

    positionedDependencies = [ ]
    for i in [0..args.length]
      positionedDependencies.push deps[args[i]]

    func.apply object, positionedDependencies
    return object

  newInstance: (buddyObject, constructorArguments = []) ->
    if not constructorArguments instanceof Array and typeof constructorArguments is "object"
      constructorArguments = @resolve buddyObject, constructorArguments

  inject: (func) =>
    dependencies = @resolve func
    func.apply object, dependencies

  resolve: (func, dependencyList = null) ->
    args = @getArguments func

    dependencies = [ ]
    for i in [0..args.length - 1]

      dependency = args[i].trim()

      if dependencyList is null
        if not @dependencies[dependency]?
          console.log '[Injector] Dependency not found: ' + dependency
          dependencies.push null # push null instead of dependency
        else
          dependencies.push @dependencies[dependency]
      else # @TODO: remove double usage
        if not dependencyList[dependency]?
          console.log '[Injector] Dependency not found in dependency list: ' + dependency
          dependencies.push null # push null instead of dependency
        else
          dependencies.push dependencyList[dependency]

    return dependencies

  getArguments: (func) ->
    functionArgs = /^function\s*[^\(]*\(\s*([^\)]*)\)/m
    args = func.toString().match(functionArgs)[1].split(',')
    return args
}