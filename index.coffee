module.exports.Task = require("./task").Task
module.exports.TaskManager = require("./task").TaskManager
module.exports.Session = require("./session")
Application = require("./Application")

module.exports.Application = Application

module.exports.ClientApplication = class ClientApplication extends Application
  constructor: (configFolder) ->
    super({ isServer: false, configurations: configFolder })

module.exports.ServerApplication = class ServerApplication extends Application
  constructor: (configFolder) ->
    super({ isServer: true, configurations: configFolder })
