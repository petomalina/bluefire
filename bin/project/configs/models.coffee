
module.exports.models = {

  ###
    If no connection is specified in the model, this one will
    be used as default
  ###
  connection: "disk"

  ###
    Migration settings for connections. There are 3 types:
    "drop" - drops all data and creates new collections
    "alter" - tries to reflect changes of database
    "safe" - won't modify collections in any way
  ###
  migrate: "drop"
}