ServerApplication = require("bluefire").ServerApplication

module.exports = class Application extends ServerApplication

  constructor: () ->
    super()

  run: () ->
    super()

  onConnect: (session) ->
    console.log("New session accepted!")