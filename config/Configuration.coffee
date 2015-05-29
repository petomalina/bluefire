
###
Class that loads the file and keeps the contents as configurations
###
module.exports = class Configuration

  constructor: (module = null) ->
    if module? and typeof module is "object"
      @data = module
    else if typeof module is "string"
      @data = require(module)
    else
      @data = { }

  add: (key, value) =>
    @data[key] = value
    return @data[key]

  get: (key) =>
    return @data[key]

  remove: (key) ->
    delete @data[key]

  ###
  Method that indicates if configuration data set is empty

  @return [Boolean] true if set is empty, else false
  ###
  empty: () ->
    return @length() is 0

  length: () ->
    return Object.keys(@data).length
