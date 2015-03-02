###
  Connections are services that are used to save or retrieve data.
  You can specify here services you want to use and link models to them,
  so you will be able to use waterline logic on them

  See documentation for waterline modules used on how to use your specified
  connection
###
module.exports .connections = {

  ###
    Default connection is set to disk. This will create database inside
    the file so you don't need to setup database.
  ###
  disk: {
    adapter: "sails-disk"
  }
}