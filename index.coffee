Application = require "./Application"


module.exports.Application = Application

module.exports.ClientApplication = class ClientApplication extends Application
  constructor: () ->
    super(false)
    
module.exports.ServerApplication = class ServerApplication extends Application
  constructor: () ->
    super(true)

module.exports.Task = require './task/Task'