
module.exports = class Task

	constructor: (@action, @options = { }) ->
		if not @options.repeat?
			@options.repeat = false
		else
			if not @options.repeatTimes?
				@options.repeatTimes = 2

		if not @options.timeout?
			@options.timeout = 1000

	perform: (context) =>
		action = new TaskAction(context, @options, @action)

		return action

class TaskAction

	constructor: (@context, @options, @callback) ->
		if @options.repeat is true
			@repeatedTimes = 1
			@action = setInterval(@perform, @options.timeout)
		else
			@action = setTimeout(@perform, @options.timeout)

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