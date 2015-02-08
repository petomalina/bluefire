###
  Main class that represents registered task. This class is using TaskAction
  to provide context for more Tasks with same type.

  @author Gelidus
  @version 0.0.3a
###
module.exports = class Task

	constructor: (action, options = { }) ->
		this.action = action
		this.options = options

		if not @options.repeat?
			@options.repeat = false
		else
			if not @options.repeatTimes?
				@options.repeatTimes = 0

		if not @options.timeout?
			@options.timeout = 0

	###
  	Method that will perform current task by creating TaskAction with the
  	given context and options (may be changed).

  	@param context [Object] Any object with which should task manipulate
  	@param options [Object] Options to be passed into the TaskAction
  	@return action [TaskAction] Currently created TaskAction
  ###
	perform: (context, options = @options) =>
		action = new TaskAction(context, options, @action)

		return action

###
  This class represents each task being made witing the given context.
  Options are derived from the main Task class.

  @author Gelidus
  @version 0.0.3a
###
class TaskAction

	constructor: (@context, @options, @callback) ->
		if @options.repeat is true
			@repeatedTimes = 1
			@action = setInterval(@perform, @options.timeout)
		else
			@action = setTimeout(@perform, @options.timeout)

	###
  	Stops the current TaskAction, any currently executing callbacks
  	won't be stopped, but no more will be executed.
	###
	stop: () =>
		if not @action?
			return

		if @options.repeat is true
			clearInterval(@action)
		else
			clearTimeout(@action)

	perform: () =>
		@callback(@context)

		if @options.repeat is true
			if @options.repeatTimes > @repeatedTimes or @options.repeatTimes is -1 # repeat infinitely when -1
				@repeatedTimes++
			else
				@stop()
				return