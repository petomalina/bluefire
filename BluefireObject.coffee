module.exports = class BluefireObject

	constructor: () ->

	@extend: (obj) ->
		for key, value of obj when key not in moduleKeywords
			@[key] = value

		obj.extended?.apply(@)
		return this

	@include: (obj) ->
		for key, value of obj when key not in moduleKeywords
			# Assign properties to the prototype
			@::[key] = value

		obj.included?.apply(@)
		return this