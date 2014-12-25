FileLoader = require '../fileLoader'
Task = require './Task'

###
Class that stores previously defined tasks. It also auto-loads all tasks
from application/tasks folder.
###
module.exports = class TaskManager

	constructor: (@taskFolder = 'application/tasks/') ->
		@tasks = { }

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
	###
	install: (callback) =>
		loader = new FileLoader()

		loader.find @taskFolder, (files) =>
			for moduleName in files
				taskOptions = require(@taskFolder + moduleName)

				args = Injector.resolve Task, taskOptions

				# get task name by the name of the file without ending
				@tasks[moduleName.split('.')[0]] = new Task(args...)
				console.log "New task registered: [#{moduleName}]"

			# add task manager to the injector services
			Injector.addService('$taskmgr', @)

			callback(null, 1)