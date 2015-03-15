#Bluefire

Lightweight TCP framework based on [node.js](http://nodejs.org/) and written in [CoffeeScript](http://coffeescript.org/)

## Features

- **Simple to use** - Both, client and server can be written in the Bluefire, while keeping configurations for packets and routes same on both sides.

- **Flexible** - Whether you need a simple application(or prototype), or you want framework to make application more structured and less error-prone, bluefire can handle that. See [examples](https://github.com/Gelidus/bluefire-examples)) for more information.

- **Real world compatible** - Whether you want to send or receive data, you will never have to handle bytes. Construct real object, bluefire will handle everything else.

- **Object oriented** - While focusing on object orientation, everything that can be object in bluefire, object is. This gives users flexibility and great ability to detect errors. You can also simply inject any service you want. [Core Services page](https://github.com/Gelidus/bluefire/wiki/Core-services) will provide you with more information.

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

## Contribute

Any contributions to the project are welcome! See Issues or Future features to find out what you can do. Also feel free to contact [me](https://github.com/Gelidus) :)

Feel free to vote on [Bluefire Trello](https://trello.com/b/tltmSctv/bluefire) for features you want to be in the framework first!

Before trying to contribute, please read [Contribute to Bluefire](https://github.com/Gelidus/bluefire/wiki/Contribute-to-Bluefire)

## Testing
```bash
npm test
```
