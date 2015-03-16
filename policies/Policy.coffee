
###
  Simple policy wrapper class
###
module.exports = class Policy

  ###
    @param name [String] name of the policy
    @param action [Function] action to be called when policy is performed
  ###
  constructor: (@name, @action) ->

  ###
    Performs the policy with given parameters
    @param session [Session] client session
    @param data [Object] currently received data
    @param next [Function] callback to be called after success
  ###
  perform: (session, data, next) =>
    @action(session, data, next)