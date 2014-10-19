tcpbuddy
========

Lightweight TCP framework for node.js

While using tcpbuddy structured approach, you need to:

1.) Create application folder in node_modules and subfolders
  - configs
  - controllers
  - models
  - policies
  - tasks
  
2.) You need to create application.coffe/js in the folder

```
Base = require 'tcpbuddy/Application'

module.exports = class Application extends Base

  constructor: (callback) ->
    super(callback)

  run: () ->
    super
```
    
You also need app.coffee starting point:

```
Application = require 'application/application'

app = new Application (err, results) ->
  if err?
    console.log err
  else
    app.run()
```
