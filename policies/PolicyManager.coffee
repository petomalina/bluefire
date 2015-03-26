FileLoader = require("../fileLoader")
Policy = require("./Policy")

module.exports = class PolicyManager

  constructor: () ->
    @policies = { }
  
  ###
    @param name [String|Array] name of policy to get
    @returns [Function|Array]
  ###
  get: (names) =>
    if typeof names is "string"
      [policyClass, policyAction] = names.split(".")
      policyAction = policyAction || "default"

      throw new Error("Policy #{names} not registered") if not @policies[policyClass].instance[policyAction]?
      return @policies[policyClass].instance[policyAction]
    else
      policies = []
      for policy in names
        [policyClass, policyAction] = policy.split(".")
        policyAction = policyAction || "default"

        throw new Error("Policy #{policy} not registered") if not @policies[policyClass].instance[policyAction]?
        policies.push(@policies[policyClass].instance[policyAction])

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
    @param policyName [String] name of the policy to be performed
  ###
  perform: (name, session, data, next, policyName) =>
    policy = @get(name)
    
    policy(session, data, next, policyName)