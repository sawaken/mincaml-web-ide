SRC = Dir.glob('./{src,ui,parser}/{*.coffee,*.cjsx,*.pegjs}')

task default: 'compile-all'

task :test do
  mocha_path = './node_modules/.bin/mocha'
  mocha_option = '--compilers coffee:coffee-script/register'
  sh "#{mocha_path} #{mocha_option} test/*.coffee"
end

task :install do
  sh 'npm install'
end

rule '.js' => '.cjsx' do |t|
  cjsx_path = './node_modules/.bin/cjsx'
  sh "#{cjsx_path} -c #{t.source}"
end

rule '.js' => '.coffee' do |t|
  coffee_path = './node_modules/.bin/coffee'
  sh "#{coffee_path} -c #{t.source}"
end

rule './parser/mincaml-parser.js' => './parser/mincaml-parser.pegjs' do |t|
  pegjs_path = './node_modules/.bin/pegjs'
  sh "#{pegjs_path} -e mincamlParser #{t.source} #{t.name}"
end

rule 'compile-all' => SRC.map { |f| f.gsub(/(\.[a-z]+$)/, '.js') }

task 'listen' do
  loop do
    `rake compile-all`
    sleep(1)
  end
end
