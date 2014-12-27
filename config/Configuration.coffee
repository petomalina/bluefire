
###
Class that loads the file and keeps the contents as configurations
###
module.exports = class Configuration

  constructor: () ->
    @data = { }

  load: (module) =>
    try
      file = require module

      for key, value of file
        @data[key] = value

    catch exception
      @data = { } # null the data

  add: (key, value) ->
    @data[key] = value

  get: (key) ->
    return @data[key]

  remove: (key) ->
    delete @data[key]

  empty: () ->
    return Object.keys(@data).length is 0