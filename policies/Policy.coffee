
###
  Simple policy wrapper class
###
module.exports = class Policy

  constructor: (@name, @action) ->

  perform: (session, data, next) =>
    @action(session, data, next)