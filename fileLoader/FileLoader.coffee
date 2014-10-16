FileSystem = require 'fs'

module.exports = class FileLoader

  constructor: (options = { }) ->
    @options = options

  find: (path, callback) =>
    if not @options.recursive?
      @options.recursive = false

    if not @options.root?
      @options.root = '/node_modules/'

    directory = process.cwd() + @options.root + path

    FileSystem.readdir directory, (err, files) =>
      callback files