#! /usr/bin/env node
'use strict';

var fs = require('fs');

// checks for available update and returns an instance
var _ = require('lodash');
var pkg = JSON.parse(fs.readFileSync(__dirname + '/../package.json'));

require('update-notifier')({
  pkg: _.defaults(pkg, { version: '0.0.0' }),
}).notify();

require('./../lib/cli.js');
