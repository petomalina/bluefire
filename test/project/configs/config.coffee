module.exports = {

  configuration: "debug" # debug, release

  port: 8888

  parser: "packetbuddy"

  packetbuddy: {
    rootNode: "packet"
    conditionField: "operation"
  }
}