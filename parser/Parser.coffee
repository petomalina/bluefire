Promise = require("promise")
Packet = require("./Packet")

module.exports = class Parser

  constructor: (@isServer) ->
    @head = new Packet("Head") # register empty head

    @serverPackets = { }
    @clientPackets = { }
    @packetConditions = { } # condition - name map

  initialize: (conditionField = "opcode") =>
    @conditionField = conditionField

  ###
  @return [Packet] packet representing head for all packets
  ###
  getHead: () =>
    return @head

  ###
  sets the current head to the given

  @param head [Packet] packet to be given as a head packet
  @return [Packet] new head packet instance
  ###
  setHead: (head) =>
    @head = head
    return @head

  ###
  Sets the condition field to the custom one

  @param conditionField[String] name of condition field in packet
  ###
  setConditionField:(@conditionField) =>

  ###
  Registers packet by given name, location and condition
  ###
  registerPacket: (packet, isServerPacket, condition = null) =>

    if isServerPacket # switch between server and client packets
      @serverPackets[packet.name] = packet
    else
      @clientPackets[packet.name] = packet

    # register condition for current packet
    if (@isServer and not isServerPacket) or (not @isServer and isServerPacket)
      @registerCondition(packet.name, condition)
    else
      packet.addPredefinedValue(@conditionField, condition) # adds as predefined value

    return packet

  packet: (name, isServerPacket, structure) =>
    condition = @findCondition(structure) # get additional condition

    packet = new Packet(name, @head)
    packet.add(structure)

    return @registerPacket(packet, isServerPacket, condition)

  ###
  Finds condition field value in the packet structure

  @param structure [Array] an array of structured for the packet
  @return [String|Integer|Null] value of condition field or null if not found
  ###
  findCondition: (structure) ->
    for field in structure
      for name, value of field
        if name is @conditionField
          return value

    return null

  ###
  Returns packet from collection by given type

  @param packetName [String] packet name from collection
  @param isServer [Boolean] true if server packet is needed, else false. Default: true
  ###
  getPacket: (packetName, isServer = true) =>
    return if isServer then @serverPackets[packetName] else @clientPackets[packetName]

  registerCondition: (packetName, condition = null) ->
    if condition? and packetName?
      @packetConditions[condition] = packetName

  ###
  Parses the given data buffer into the structure which
  represents the given packet by conditionField from head

  @param buffer [Buffer] buffer to be parsed
  @param callback [Function(name,data)] callback to be called after parse
  @param packetname [String] optional packet name if already known
  ###
  parse: (buffer, packetName = null) =>
    return new Promise (fulfill, reject) =>
      parsedData = { }
      head = @getHead()
      index = 0 # current byte index for parser

      # read whole head
      for parser in head.packetParseData
        name = parser["name"]
        read = parser["read"]

        [parsedData[name], index] = read(buffer, index)

      # parse packets that are oposite
      name = if packetName? then packetName else @packetConditions[parsedData[@conditionField]]
      packet = @getPacket(name, !@isServer)

      if not packet?
        reject(new Error("Packet not found"))
        return

      for parser in packet.packetParseData
        name = parser["name"]
        read = parser["read"]

        [parsedData[name], index] = read(buffer, index)

      fulfill({name: packet.name, data: parsedData})

  ###
  Creates byte buffer that can be passed right into socket with current
  packet structure

  @param data [Object] data to be serialized
  @param packetName [String] name of packet to serialize
  @param callback [Function] function to be called

  @example Serialization of previously registered packet with name 'myPacket'
    serialize { myInt : 5}, 'myPacket', (buffer) ->
      #send buffer or do something else
  ###
  serialize: (data, packetName) =>
    return new Promise (fulfill, reject) =>
      # serialize packets from this side
      packet = @getPacket(packetName, @isServer)
      bufferArray = []

      for parser in packet.head.packetParseData
        name = parser['name']
        write = parser['write']

        data[name] = packet.predefinedValues[name] if not data[name]? and packet.predefinedValues[name]?
        bufferArray.push(write(data[name]))

      for parser in packet.packetParseData
        name = parser['name']
        write = parser['write']

        data[name] = packet.predefinedValues[name] if not data[name]? and packet.predefinedValues[name]?

        bufferArray.push(write(data[name]))

      fulfill(Buffer.concat(bufferArray)) # glue up whole array of buffers
