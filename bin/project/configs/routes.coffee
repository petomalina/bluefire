###
  This module consists of Packet names that route into some controller
  and it's action.
###
module.exports = {

  ###
    Every route should have associated:
    - packet name
    - controller
    - action in controller
  ###

  # redirect MyPacket from "packets" configuration to controller named "PingController"
  # and action "onPing"

  # MyPacket: { controller: "PingController", action: "onPing" }
}