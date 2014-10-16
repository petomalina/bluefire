module.exports = {

  dependencies: { }

  register: (name, dependency) ->
    @dependencies['$' + name] = dependency

  injectWithDependencies: (func, deps) ->
    object = new func
    args = @getArguments func

    positionedDependencies = [ ]
    for i in [0..args.length]
      positionedDependencies.push deps[args[i]]

    func.apply object, positionedDependencies
    return object


  inject: (func) =>
    dependencies = @resolve func
    func.apply object, dependencies

  resolve: (func, dependencyList = null) ->
    args = @getArguments func

    dependencies = [ ]
    for i in [0..args.length - 1]

      dependency = args[i].trim()
      if dependency[0] is '$'
        dependency = args[i].substring(1) # $ character in injection

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