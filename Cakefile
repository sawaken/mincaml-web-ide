require 'shelljs/global'

task 'test', 'run test/*.coffee', (option) ->
  mochaPath = './node_modules/.bin/mocha'
  mochaOption = '--compilers coffee:coffee-script/register'
  result = exec "#{mochaPath} #{mochaOption} test/*.coffee"
  exit(result.code)
