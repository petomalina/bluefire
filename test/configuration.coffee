assert = require("assert")
Configuration = require '../config/Configuration'
require 'should'

describe 'Configuration', () ->
	conf = new Configuration

	describe '#add()', () ->
		it 'should add key-value pair into configuration', () ->
			conf.add 'key', 'value'
			conf.add 'key2', null
			conf.add 'testkey', new Object

			Object.keys(conf.data).length.should.be.exactly(3)

	describe '#get()', () ->
		it 'should get key-value pair from configuration', () ->
			assert.equal 'value', conf.get 'key'
			assert.equal null, conf.get 'key2'
			assert.notEqual null, conf.get 'testkey'

	describe '#length', () ->
		it 'should return length of current configuration', () ->
			assert.equal Object.keys(conf.data).length, conf.length()

	describe '#remove()', () ->
		it 'should remove key-value pair from configuration', () ->
			conf.remove 'key2'
			assert.equal 2, conf.length()
			conf.remove 'key'
			assert.equal null, conf.get 'key'

	describe '#empty()', () ->
		it 'should return false is configuration is empty', () ->
			conf.empty().should.be.false
			conf.remove 'testkey'
			conf.empty().should.be.true