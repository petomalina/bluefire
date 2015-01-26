###
  This module consists of Packet names that route into some controller
  and it's action.
###
module.exports = {

  ###
  Registers route for Ping packet into Ping controller and it's onPing action
  ###
  Ping: { controller: "Ping", action: "onPing" }
}