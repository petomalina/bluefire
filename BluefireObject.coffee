_ = require("underscore")

module.exports = class BluefireObject

	constructor: () ->

	extends: (something) =>
		_.extend(@, something)