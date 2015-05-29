Include = require("include-all")
Configuration = require("./Configuration")

###
  Class that handles and stores all configuration files from the given directory
###
module.exports = class ConfigurationManager

  constructor: (@baseDir) ->
    if not @baseDir?
      throw new Error("You must specify base directory in ConfigurationManager to correctly initialize it")

    @configurations = { }

  load: (callback) =>
    configs = Include({
      dirname: @baseDir
      filter: /(.*)\.(coffee|js)/
      excludeDirs: /^\.(git|svn)$/
    })

    for name, config of configs
      @configuration(name, config)

    callback(null)

  configuration: (name, module) =>
    @configurations[name] = new Configuration(module)

    return @configurations[name]

  get: (name) =>
    if not @configurations[name]?
      @configurations[name] = new Configuration # create new configuration so we can pass it

    return @configurations[name]
