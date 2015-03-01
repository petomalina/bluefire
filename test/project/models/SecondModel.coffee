
module.exports = {

  tableName: "second"

  attributes: {
    id: {
      type: "integer"
      unique: true
      required: true
    }

    second: {
      type: "string"
      required: true
    }
  }
}