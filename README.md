#Bluefire

Lightweight TCP framework based on [node.js](http://nodejs.org/) and written in [CoffeeScript](http://coffeescript.org/)

## Features

- **Write once, run twice** - Client and server can be written in the Bluefire, while keeping configurations for packets and routes same on both sides.

- **Take what you need** - Whether you need a simple application(or prototype), or you want framework to make application more structured and less error-prone, you will have that. These two approaches can be also mixed together (see [examples](https://github.com/Gelidus/bluefire-examples))

- **Manipulate with real objects, not buffers** - Whether you want to send or receive, you will never have to handle bytes. Construct real object, framework will handle everything else.

- **Injections, injections everywhere** - Why should you globalize objects, when you can access them in cool way? [Core Services page](https://github.com/Gelidus/bluefire/wiki/Core-services) will provide you with more information.

Feel free to vote on [Bluefire Trello](https://trello.com/b/tltmSctv/bluefire) for features you want to be in the framework first!

## Installation [![npm version](https://badge.fury.io/js/bluefire.svg)](http://badge.fury.io/js/bluefire)[![Build Status](https://travis-ci.org/Gelidus/bluefire.svg?branch=master)](https://travis-ci.org/Gelidus/bluefire)

Be sure to install [node.js](http://nodejs.org/) first. Then:
```sh
$ sudo npm install -g bluefire
```

If you want to use [structured approach to bluefire](https://github.com/Gelidus/bluefire/wiki/Structured-approach) (in directory you want new project):
```sh
$ bluefire new myproject # this will create new server project
```

## Usage

See [step by step wiki guide](https://github.com/Gelidus/bluefire/wiki/Step--by-step-guide).

## Examples

See [examples repository](https://github.com/Gelidus/bluefire-examples).

## API

Check [wiki](https://github.com/Gelidus/bluefire/wiki) for Bluefire API usage.

## ORM/ODM Compatibility

Check [wiki](https://github.com/Gelidus/bluefire/wiki/ORM-ODM-Compatibility) for ORM/ODM Compatibility.

## Contribute

Any contributions to the project are welcome! See Issues or Future features to find out what you can do. Also feel free to contact [me](https://github.com/Gelidus) :)

Before trying to contribute, please read [Contribute to Bluefire](https://github.com/Gelidus/bluefire/wiki/Contribute-to-Bluefire)

## Testing
```bash
npm test
```
