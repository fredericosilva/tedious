parser = require('../../../lib/token/row-token-parser')
dataTypeByName = require('../../../lib/token/data-type').typeByName
ReadableTrackingBuffer = require('../../../lib/tracking-buffer/tracking-buffer').ReadableTrackingBuffer
WritableTrackingBuffer = require('../../../lib/tracking-buffer/tracking-buffer').WritableTrackingBuffer

module.exports.bigint = (test) ->
  colMetaData = [{type: dataTypeByName.BigInt},
                 {type: dataTypeByName.BigInt}]

  buffer = new WritableTrackingBuffer(0, 'ucs2')
  buffer.writeBuffer(new Buffer([
      1,0,0,0,0,0,0,0,
      255,255,255,255,255,255,255,127]))

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)

  test.strictEqual(token.columns.length, 2)
  test.strictEqual("1", token.columns[0].value)
  test.strictEqual("9223372036854775807", token.columns[1].value)

  test.done()


module.exports.null = (test) ->
  colMetaData = [type: dataTypeByName.Null]

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(token.columns[0].isNull)
  test.ok(!token.columns[0].value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.int = (test) ->
  colMetaData = [type: dataTypeByName.Int]
  value = 3

  buffer = new WritableTrackingBuffer(0, 'ucs2')
  buffer.writeUInt32LE(value)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.varChar = (test) ->
  colMetaData = [type: dataTypeByName.VarChar]
  value = 'abc'

  buffer = new WritableTrackingBuffer(0, 'ascii')
  buffer.writeUsVarchar(value)
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.nVarChar = (test) ->
  colMetaData = [type: dataTypeByName.NVarChar]
  value = 'abc'

  buffer = new WritableTrackingBuffer(0, 'ucs2')
  buffer.writeUInt16LE(value.length * 2)
  buffer.writeString(value)
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.varCharMaxNull = (test) ->
  colMetaData = [
    type: dataTypeByName.VarChar
    dataLength: 65535
  ]
  value = 'abcdef'

  buffer = new WritableTrackingBuffer(0, 'ascii')
  buffer.writeBuffer(new Buffer([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]))
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(token.columns[0].isNull)
  test.ok(!token.columns[0].value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.varCharMaxUnknownLength = (test) ->
  colMetaData = [
    type: dataTypeByName.VarChar
    dataLength: 65535
  ]
  value = 'abcdef'

  buffer = new WritableTrackingBuffer(0, 'ascii')
  buffer.writeBuffer(new Buffer([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE]))
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(0, 3))
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(3, 6))
  buffer.writeUInt32LE(0)
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.varCharMaxKnownLength = (test) ->
  colMetaData = [
    type: dataTypeByName.VarChar
    dataLength: 65535
  ]
  value = 'abcdef'

  buffer = new WritableTrackingBuffer(0, 'ascii')
  buffer.writeUInt64LE(value.length)
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(0, 3))
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(3, 6))
  buffer.writeUInt32LE(0)
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)
  test.strictEqual(token.columns[0].metadata, colMetaData[0])

  test.done()

module.exports.varCharMaxKnownLengthWrong = (test) ->
  colMetaData = [
    type: dataTypeByName.VarChar
    dataLength: 65535
  ]
  value = 'abcdef'

  buffer = new WritableTrackingBuffer(0, 'ascii')
  buffer.writeUInt64LE(value.length + 1)
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(0, 3))
  buffer.writeUInt32LE(3)
  buffer.writeString(value.slice(3, 6))
  buffer.writeUInt32LE(0)
  #console.log(buffer.data)

  try
    token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
    test.ok(false)
  catch exception
    test.done()

module.exports.intN = (test) ->
  colMetaData = [{type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN},
                 {type: dataTypeByName.IntN}]

  buffer = new WritableTrackingBuffer(0, 'ucs2')
  buffer.writeBuffer(new Buffer([
      0,
      8, 0,0,0,0,0,0,0,0,
      8, 1,0,0,0,0,0,0,0,
      8, 255,255,255,255,255,255,255,255,
      8, 2,0,0,0,0,0,0,0,
      8, 254,255,255,255,255,255,255,255,
      8, 255,255,255,255,255,255,255,127,
      8, 0,0,0,0,0,0,0,128,
      8, 10,0,0,0,0,0,0,0,
      8, 100,0,0,0,0,0,0,0,
      8, 232,3,0,0,0,0,0,0,
      8, 16,39,0,0,0,0,0,0]))
  #console.log(buffer.data)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 12)
  test.ok(!token.columns[0].value)
  test.ok(token.columns[0].isNull)
  test.strictEqual("0", token.columns[1].value)
  test.strictEqual("1", token.columns[2].value)
  test.strictEqual("-1", token.columns[3].value)
  test.strictEqual("2", token.columns[4].value)
  test.strictEqual("-2", token.columns[5].value)
  test.strictEqual("9223372036854775807", token.columns[6].value)
  test.strictEqual("-9223372036854775808", token.columns[7].value)
  test.strictEqual("10", token.columns[8].value)
  test.strictEqual("100", token.columns[9].value)
  test.strictEqual("1000", token.columns[10].value)
  test.strictEqual("10000", token.columns[11].value)

  test.done()

module.exports.datetime = (test) ->
  colMetaData = [type: dataTypeByName.DateTime]

  days = 2                                        # 3rd January 1900
  threeHundredthsOfSecond = 45 * 300              # 45 seconds

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeInt32LE(days)
  buffer.writeUInt32LE(threeHundredthsOfSecond)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value.getTime(), new Date('January 3, 1900 00:00:45').getTime())

  test.done()

module.exports.datetimeN = (test) ->
  colMetaData = [type: dataTypeByName.DateTimeN]

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(0)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].value)
  test.ok(token.columns[0].isNull)

  test.done()

module.exports.numeric4Bytes = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 3
    scale: 1
  ]

  value = 9.3

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(1 + 4)
  buffer.writeUInt8(1)      # positive
  buffer.writeUInt32LE(93)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)

  test.done()

module.exports.numeric4BytesNegative = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 3
    scale: 1
  ]

  value = -9.3

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(1 + 4)
  buffer.writeUInt8(0)      # negative
  buffer.writeUInt32LE(93)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)

  test.done()

module.exports.numeric8Bytes = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 13
    scale: 1
  ]

  value = (0x100000000 + 93) / 10

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(1 + 8)
  buffer.writeUInt8(1)      # positive
  buffer.writeUInt32LE(93)
  buffer.writeUInt32LE(1)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)

  test.done()

module.exports.numeric12Bytes = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 23
    scale: 1
  ]

  value = ((0x100000000 * 0x100000000) + 0x200000000 + 93) / 10

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(1 + 12)
  buffer.writeUInt8(1)      # positive
  buffer.writeUInt32LE(93)
  buffer.writeUInt32LE(2)
  buffer.writeUInt32LE(1)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)

  test.done()

module.exports.numeric16Bytes = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 33
    scale: 1
  ]

  value = ((0x100000000 * 0x100000000 * 0x100000000) + (0x200000000 * 0x100000000) + 0x300000000 + 93) / 10

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(1 + 16)
  buffer.writeUInt8(1)      # positive
  buffer.writeUInt32LE(93)
  buffer.writeUInt32LE(3)
  buffer.writeUInt32LE(2)
  buffer.writeUInt32LE(1)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].isNull)
  test.strictEqual(token.columns[0].value, value)

  test.done()

module.exports.numericNull = (test) ->
  colMetaData = [
    type: dataTypeByName.NumericN
    precision: 3
    scale: 1
  ]

  buffer = new WritableTrackingBuffer(0, 'ucs2')

  buffer.writeUInt8(0)
  #console.log(buffer)

  token = parser(new ReadableTrackingBuffer(buffer.data, 'ucs2'), colMetaData)
  #console.log(token)

  test.strictEqual(token.columns.length, 1)
  test.ok(!token.columns[0].value)
  test.ok(token.columns[0].isNull)

  test.done()