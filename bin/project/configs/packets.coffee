###
  This module encapsulates configuration for each packet sent (protocol).
  It consists of 2 sub-namespaces (client and server packets)

  Head is first part of each packet, it must have conditionField(set in config of parser)
  in it. After that, you can set default values for previously defined fields.
  This means, when sending, you are not supposed to write all the fields,
  just that you want to change from defaults.
###
module.exports = {

  ###
    All fields from head packet will be in front of each packet, also,
    opcode here means conditionField (from parser config)
  ###
  Head: [
    opcode: 'uint8'
  ]

  ###
    Namespace for packets that are sent from client
  ###
  ClientPackets: {

    ###
      Register packet named "Ping" that will be sent by client
    ###
    #Ping: [
    #  opcode: 0 # means default value of opcode for this packet is 0
    #, value: 'stringle'
    #]
  }

  ###
    Namespace for packets that are send from server
  ###
  ServerPackets: {

    ###
      Register packet named "Ping" that will be sent by server
    ###
    #Ping: [
    #  opcode: 0 # means default value of opcode for this packet is 0
    #, value: 'stringle'
    #]
  }
}