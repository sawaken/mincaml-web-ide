{exec} = require 'child_process'

task 'test', 'run test/*.coffee', (option) ->
  exec './node_modules/.bin/mocha --compilers coffee:coffee-script/register test/*.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr