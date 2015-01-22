FileSystem = require 'fs'

###
Fileloader class is wrapper class for finding files in the directory of node_modules
###
module.exports = class FileLoader

  ###
  @param options [Object] FileLoader options. May be recursive(true|false) and root(will override node_modules relative to the root)
  ###
  constructor: (@options = { }) ->

  ###
  Finds all files in the given path (relative to node_modules/). If directory does
  not exist or is empty, return array is empty

  @param path [String] relative path to node_modules/
  @param callback [Function] callback function with array of file names
  ###
  find: (path, callback) =>
    if not @options.recursive?
      @options.recursive = false

    if not @options.root?
      @options.root = ''

    directory = @options.root + path

    FileSystem.readdir directory, (err, files) =>
      if err?
        callback([])
      else
        callback(files)