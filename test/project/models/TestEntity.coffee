
module.exports = {

  tableName: "test"

  attributes: {
    id: {
      type: "integer"
      unique: true
      required: true
    }

    text: {
      type: "string"
      required: true
    }
  }
}