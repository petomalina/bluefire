Packet = require('./Packet')

module.exports = class Parser

  constructor: (isServer, head) ->
    this.isServer = isServer

    @conditionField = "opcode"

    @head = if head? then head else new Packet("Head") # register empty head

    @serverPackets = { }
    @clientPackets = { }
    @packetConditions = { } # condition - name map

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
  setConditionField:(@conditionField) ->

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
  parse: (buffer, callback, packetName = null) ->
    parsedData = { }
    head = @getHead()
    index = 0 # current byte index for parser

    # read whole head
    for parser in head.packetParseData
      name = parser["name"]
      read = parser["read"]

      [parsedData[name], index] = read(buffer, index)

    # parse packets that are oposite
    packet = @getPacket(@packetConditions[parsedData[@conditionField]], !@isServer)

    if not packet?
      callback(null, null)
      return

    for parser in packet.packetParseData
      name = parser["name"]
      read = parser["read"]

      [parsedData[name], index] = read(buffer, index)

    callback(packet.name, parsedData)

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
  serialize: (data, packetName, callback) =>
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

    callback(Buffer.concat(bufferArray)) # glue up whole array of buffers