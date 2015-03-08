module.exports = {

  configuration: "debug" # debug, release

  port: 9999

  parser: "packetbuddy"

  packetbuddy: {
    rootNode: "packet"
    conditionField: "operation"
  }
}