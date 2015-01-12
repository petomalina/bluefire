
module.exports = class Packet

	constructor: (@name) ->
    @packetParseData = [] # array to store parse objects

  ###
  Adds key-value pairs into the packet structure specifiing their name and type

  @param structure [Array] array of key-value pairs where key is name and value is type
  @return [Packet] current packet
  ###
  add: (structure) ->
    for field, type of structure
      switch type
        when "uint8" then @addUInt8 field
        when "int8" then @addInt8 field
        when "uint16le" then @addUInt16LE field
        when "uint32le" then @addUInt32LE field
        when "int16le" then @addInt16LE field
        when "int32le" then @addInt32LE field
        when "floatle" then @addFloatLE field
        when "doublele" then @addDoubleLE field
        when "stringle" then @addStringLE field
        when /uint8 array [0-9]+:[0-9]+/ then @addUInt8Array field, field.split(' ')[2]
        when /uint16le array [0-9]+:[0-9]+/ then @addUInt16LEArray field, field.split(' ')[2]

    return @

  addUInt8: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readUInt8(index), index + 1 ]

      write: (data) ->
        addBuffer = new Buffer(1)
        addBuffer.writeUInt8(data, 0)

        return addBuffer
    }

    return @

  addInt8: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readInt8(index), index + 1 ]

      write: (data) ->
        addBuffer = new Buffer(1)
        addBuffer.writeInt8(data, index)

        return addBuffer
    }

    return @

  addUInt16LE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readUInt16LE(index), index + 2 ]

      write: (buffer, data) ->
        addBuffer = new Buffer(2)
        addBuffer.writeUInt16LE(data, 0)

        return addBuffer
    }

    return @

  addUInt32LE: (name) -> 
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readUInt32LE(index), index + 4 ]

      write: (buffer, data) ->
        addBuffer = new Buffer(4)
        addBuffer.writeUInt32LE(data, 0)

        return addBuffer
    }

    return @

  # change return buffer on methods above : TODO
  addInt16LE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readInt16LE(index), index + 2 ]

      write: (buffer, data) ->
        return [ buffer.writeInt16LE(data, buffer.length), index + 2 ]
    }

    return @

  addInt32LE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readInt32LE(index), index + 4 ]

      write: (buffer, data) ->
        return [ buffer.writeInt32LE(data, buffer.length), index + 4 ]
    }

    return @

  addDoubleLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readDoubleLE(index), index + 8 ]

      write: (buffer, data) ->
        return [ buffer.writeDoubleLE(data, buffer.length), index + 8 ]
    }

    return @

  addFloatLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readFloatLE(index), index + 4 ]

      write: (buffer, data) ->
        return [ buffer.writeFloatLE(data, buffer.length), index + 4 ]
    }

    return @

  # change return type on above method (write)
  addStringLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = ""
        char = buffer.readUInt8(index)
        i = 1

        while char != '\0'
          data += String.fromCharCode(char)
          char = buffer.readUInt8

        return [ data, index + i ];

      write: (buffer, data) ->
        for character in data
          buffer.writeUInt8(character, buffer.length)

        buffer.writeUInt8('\0', buffer.length) # terminate by zero

        return index + data.length + 1 # 1 = \0 at the end
    }

    return @

  addUInt8Array: (name, number) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = []

        for i in [0..number-1]
          data.push buffer.readUInt8(index + i)

        return [ data, index + number ]

      write: (buffer, data) ->
        for i in [0..number-1]
          buffer.writeUInt8 data[i]

        return index + number
    }

    return @

  addUInt16LEArray: (name, number) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = []

        for i in [0..number-1]
          data.push(buffer.readUInt16LE(inde + i))

        return [ data, index + number ]

      write: (buffer, data) ->
        for i in [0..number-1]
          buffer.writeUInt8(data[i])

        return index + number
    }

    return @