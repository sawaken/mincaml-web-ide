task :test do
  mochaPath = './node_modules/.bin/mocha'
  mochaOption = '--compilers coffee:coffee-script/register'
  sh "#{mochaPath} #{mochaOption} test/*.coffee"
end
