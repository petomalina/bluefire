FileLoader = require("../fileLoader")
Policy = require("./Policy")

module.exports = class PolicyManager

  constructor: () ->
    @policies = { }
  
  ###
    @param name [String|Array] name of policy to get
    @returns [Policy|Array]
  ###
  get: (names) =>
    if typeof names is "string"
      return @policies[names]
    else
      policies = []
      policies.push(@get(policy)) for policy in names

      return policies

  install: (callback, policiesFolder = "#{global.CurrentWorkingDirectory}/policies/") =>
    loader = new FileLoader
    
    loader.find policiesFolder, (err, files) =>
      for moduleName in files
        continue if /^\..*$/.test(moduleName) # continue if dot file (.gitkeep)

        check = require(policiesFolder + moduleName)
        
        @policy(moduleName.split(".")[0], check)

      callback()
        
  policy: (name, check) =>
    @policies[name] = new Policy(name, check)
    
  ###
    @param name [String] name of policy to perform
    @param session [Session] session which is affected
    @param data [Object] data on route
    @param next [Function] next thing to do
  ###
  perform: (name, session, data, next) =>
    policy = @get(name)
    throw new Error("Policy #{name} not registered") if not policy?
    
    policy.perform(session, data, next)