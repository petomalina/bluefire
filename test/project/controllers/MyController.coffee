
module.exports = class MyController

  constructor: () ->

  myAction: (session, data) =>
    session.myAction = true # set that myAction was performed
    data.done() if data.done? # call done method if present