###
  This module consists of services that should be created.
  You should register here your database connections, cache,
  helper services etc.

  These modules will be singletons in whole project. While
  injecting them, only the same instance will be passed each
  time.
###
module.exports = {

  ###
  # Simple example

  Database: {
    module: "sequelize"

    arguments: {
      database: "my_database"
      username: "my_user"
      password: "my_password"

      options: {
        dialect: "postgres"
      }
    }
  }
  ###

  ###
  # Extended example

  Database: {
    module: "sequelize" # this is now only supported ORM

    # arguments that should be passed into the module, see
    # documentation on what should be passed
    arguments: {
      database: "my_database"
      username: "my_user"
      password: "my_password"

      options: {
        # you will need appropriate module
        dialect: "postgres" # or mysql, sqlite, mariasql
        port: 5432

        define: {
          # camel case may cause errors on some configurations of postgres
          createdAt: "created_at"
          updatedAt: "updated_at"
          deletedAt: "deleted_at"
        }

        # enable/disable logging of database queries
        # logging: () ->
      }
    }

    # lifecycle methods
    beforeCreate: (options, moduleArgs) ->

    afterCreate: (service) ->
      service.authenticate().complete(err) -> # authenticate with service
        console.log err if err?
  }
  ###
}