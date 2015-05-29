Include = require("include-all")
Task = require("./Task")

###
  Class that stores previously defined tasks. It also auto-loads all tasks
  from application/tasks folder.

  @author Gelidus
  @version 0.0.3a
###
module.exports = class TaskManager

  constructor: () ->
    @tasks = { }

  ###
      Registers new task into the current TaskManager
    ###
  task: (name, options = { }, action) ->
    args = Injector.resolve Task, { options : options, action: action }

    # get task name by the name of the file without ending
    @tasks[name] = new Task(args...)
    return @tasks[name]

  ###
    @return [Task] Returns task from tasks map or null when no task is defined
  ###
  get: (name) ->
    return @tasks[name]

  ###
    Performs the task.

    @param name [String] name of the task to be performed
    @param context [Object] context under which should be task pefrormed
  ###
  perform: (name, context) ->
    return @get(name).perform(context)

  ###
    Installs the task manager.

    @param callback [Function] callback to be performed after install
    @param taskFOlder [String] Folder to look into for tasks
  ###
  install: (callback, taskFolder = "#{global.CurrentWorkingDirectory}/tasks/") =>

    tasks = Include({
      dirname: taskFolder
      filter: /(.*)(Job|Task)\.(coffee|js)/
      excludeDirs: /^\.(git|svn)$/
    })

    for name, taskopts of tasks
      @task(name, taskopts.options, taskopts.action)

      callback(null) if callback?
