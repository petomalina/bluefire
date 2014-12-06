FileLoader = require '../fileLoader'
Task = require './Task'

module.exports = class TaskManager

	constructor: (@taskFolder = 'application/tasks/') ->
		@tasks = { }

		Injector.addService('$taskmgr', @)

	get: (name) ->
		return @tasks[name]

	perform: (name, context) ->
		return @get(name).perform(context)

	install: (callback) =>
		loader = new FileLoader

		loader.find @taskFolder, (files) =>
			if files?
				for moduleName in files
					taskOptions = require(@taskFolder + moduleName)

					args = Injector.resolve Task, taskOptions

					@tasks[moduleName.split('.')[0]] = new Task(args...)
					console.log "New task registered: [#{moduleName}]"
			else
				console.log "No files found in dir: #{@tasksFolder}"

			callback(null, 1)