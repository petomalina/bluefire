
module.exports = class Packet

  constructor: (@name, @head) ->
    @packetParseData = [ ] # array to store parse objects
    @predefinedValues = { }

  ###
  Adds key-value pairs into the packet structure specifiing their name and type

  @param structure [Array] array of key-value pairs where key is name and value is type
  @return [Packet] current packet
  ###
  add: (structure) ->
    for node in structure
      for field, type of node
        # try to add predefined value, if field already exists, we should continue
        continue if @addPredefinedValue(field, type)

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
          when /uint32le array [0-9]+:[0-9]+/ then @addUInt32LEArray field, field.split(' ')[2]

    return @

  isAlreadyDefined: (name) =>
    if @head?
      for parser in @head.packetParseData
        return true if parser.name is name

    for parser in @packetParseData
      return true if parser.name is name

    return false

  addPredefinedValue: (field, value) =>
    if @isAlreadyDefined(field)
      @predefinedValues[field] = value # already defined (wants default value assign)  
      return true
    else
      return false  

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

      write: (data) ->
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

      write: (data) ->
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

      write: (data) ->
        addBuffer = new Buffer(2)
        addBuffer.writeInt16LE(data, buffer.length)

        return addBuffer
    }

    return @

  addInt32LE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readInt32LE(index), index + 4 ]

      write: (data) ->
        addBuffer = new Buffer(4)
        addBuffer.writeInt32LE(data, 0)

        return addBuffer
    }

    return @

  addDoubleLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readDoubleLE(index), index + 8 ]

      write: (data) ->
        addBuffer = new Buffer(8)
        addBuffer.writeDoubleLE(data, 0)

        return addBuffer
    }

    return @

  addFloatLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        return [ buffer.readFloatLE(index), index + 4 ]

      write: (data) ->
        addBuffer = new Buffer(4)
        addBuffer.writeFloatLE(data, 0)

        return addBuffer
    }

    return @

  # change return type on above method (write)
  addStringLE: (name) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = ""
        i = 0

        loop
          char = buffer.readUInt8(index+i)
          break if char is 0

          data += String.fromCharCode(char)
          i++

        return [ data, index + i + 1];

      write: (data) ->
        buffer = new Buffer(data.length + 1)
        #for i in [0..data.length-1]
        #  buffer.writeUInt8(data.charCodeAt(i), i) # copy each character to the uint8 array
        buffer.write(data, "ascii")

        buffer.writeUInt8(0, buffer.length-1) # terminate by zero

        return buffer
    }

    return @

  addUInt8Array: (name, count) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = []

        for i in [0..count-1]
          data.push(buffer.readUInt8(index + i))

        return [ data, index + count ]

      write: (data) ->
        addBuffer = new Buffer(count)
        for i in [0..count-1]
          addBuffer.writeUInt8(data[i], i)

        return addBuffer
    }

    return @

  addUInt16LEArray: (name, count) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = []

        for i in [0..count-1]
          data.push(buffer.readUInt16LE(index + i))

        return [ data, index + count ]

      write: (data) ->
        addBuffer = new Buffer(count)
        for i in [0..count-1]
          addBuffer.writeUInt16LE(data[i], i)

        return addBuffer
    }

    return @

  addUInt32LEArray: (name, count) ->
    @packetParseData.push {
      name: name

      read: (buffer, index) ->
        data = []

        for i in [0..count-1]
          data.push(buffer.readUInt32LE(index + i))

        return [ data, index + count ]

      write: (data) ->
        addBuffer = new Buffer(count)
        for i in [0..count-1]
          addBuffer.writeUInt32LE(data[i], i)

        return addBuffer
    }

    return @