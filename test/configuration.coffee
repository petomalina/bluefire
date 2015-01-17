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
			'value'.should.eql(conf.get('key'))
			(conf.get('key2') is null).should.be.true
			(conf.get('testkey') is null).should.not.be.true

	describe '#length', () ->
		it 'should return length of current configuration', () ->
			Object.keys(conf.data).length.should.be.eql(conf.length())

	describe '#remove()', () ->
		it 'should remove key-value pair from configuration', () ->
			conf.remove 'key2'
			conf.length().should.be.eql(2)
			conf.remove 'key'
			(conf.get('key') is null).should.not.be.true

	describe '#empty()', () ->
		it 'should return false is configuration is empty', () ->
			conf.empty().should.be.false
			conf.remove 'testkey'
			conf.empty().should.be.true