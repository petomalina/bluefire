Application = require("./Application")

app = new Application

app.install (err, result) ->
  if err?
    console.log err
  else
    app.run()
    console.log("Server is running")