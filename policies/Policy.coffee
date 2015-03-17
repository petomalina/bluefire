
###
  Simple policy wrapper class
###
module.exports = class Policy

  ###
    @param name [String] name of the policy
    @param action [Function] action to be called when policy is performed
  ###
  constructor: (@name, cls) ->
    @instance = Injector.create(cls)

  ###
    Performs the policy with given parameters
    @param session [Session] client session
    @param data [Object] currently received data
    @param next [Function] callback to be called after success
    @param policyName [String] Name of policy to be called
  ###
  perform: (session, data, next, policyName = "default") =>
    @instance[policyName](session, data, next) # call policy