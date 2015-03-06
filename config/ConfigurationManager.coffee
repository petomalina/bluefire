FileLoader = require("../fileLoader")
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
    fileIterator = new FileLoader
    
    fileIterator.find @baseDir, (err, files) =>
      callback(err) if err?
      
      for file in files
        continue if not /\w+\..+/.test(file) # ignore dot files
        
        configurationName = file.split('.')[0]
        @configuration(@baseDir + configurationName, configurationName)
        
      callback(null)
        
  configuration: (module, name) =>
    configuration = new Configuration(module)
    configuration.load()
      
    @configurations[name] = configuration
    
    return configuration
    
  get: (name) =>
    if not @configurations[name]?
      @configurations[name] = new Configuration # create new configuration so we can pass it
    
    return @configurations[name]