begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'socket'
require 'rake/testtask'
require 'tmpdir'
require 'securerandom'
require 'json'
require 'web_console/testing/erb_precompiler'

EXPANDED_CWD = File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

namespace :test do
  desc "Run tests for templates"
  task templates: "templates:all"

  namespace :templates do
    task all: [ :daemonize, :npm, :rackup, :mocha, :kill, :exit ]
    task serve: [ :npm, :rackup ]

    work_dir    = Pathname(__FILE__).dirname.join("test/templates")
    pid_file    = Pathname(Dir.tmpdir).join("web_console.#{SecureRandom.uuid}.pid")
    server_port = 29292
    rackup_opts = "-p #{server_port}"
    test_runner = "http://localhost:#{server_port}/html/spec_runner.html"
    test_result = nil

    task :daemonize do
      rackup_opts += " -D -P #{pid_file}"
    end

    task :npm do
      Dir.chdir(work_dir) { system "npm install --silent" }
    end

    task :rackup do
      Dir.chdir(work_dir) { system "bundle exec rackup #{rackup_opts}" }
    end

    task :mocha do
      Dir.chdir(work_dir) { test_result = system("$(npm bin)/mocha-phantomjs #{test_runner}") }
    end

    task :kill do
      system "kill #{File.read pid_file}"
    end

    task :exit do
      exit test_result
    end
  end
end

namespace :ext do
  rootdir = Pathname('extensions')

  desc 'Build Chrome Extension'
  task chrome: 'chrome:build'

  namespace :chrome do
    dist   = Pathname('dist/crx')
    extdir = rootdir.join(dist)
    manifest_json = rootdir.join('chrome/manifest.json')

    directory extdir

    task build: [ extdir, 'lib:templates' ] do
      cd rootdir do
        cp_r [ 'img/', 'tmp/lib/' ], dist
        `cd chrome && git ls-files`.split("\n").each do |src|
          dest = dist.join(src)
          mkdir_p dest.dirname
          cp Pathname('chrome').join(src), dest
        end
      end
    end

    # Generate a .crx file.
    task crx: [ :build, :npm ] do
      out = "crx-web-console-#{JSON.parse(File.read(manifest_json))["version"]}.crx"
      cd(extdir) { sh "node \"$(npm bin)/crx\" pack ./ -p ../crx-web-console.pem -o ../#{out}" }
    end

    # Generate a .zip file for Chrome Web Store.
    task zip: [ :build ] do
      version = JSON.parse(File.read(manifest_json))["version"]
      cd(extdir) { sh "zip -r ../crx-web-console-#{version}.zip ./" }
    end

    desc 'Launch a browser with the chrome extension.'
    task run: [ :build ] do
      cd(rootdir) { sh "sh ./script/run_chrome.sh --load-extension=#{dist}" }
    end
  end

  task :npm do
    cd(rootdir) { sh "npm install --silent" }
  end

  namespace :lib do
    templates = Pathname('lib/web_console/templates')
    tmplib    = rootdir.join('tmp/lib/')
    js_erb    = FileList.new(templates.join('**/*.js.erb'))
    dirs      = js_erb.pathmap("%{^#{templates},#{tmplib}}d")

    task templates: dirs + js_erb.pathmap("%{^#{templates},#{tmplib}}X")

    dirs.each { |d| directory d }
    rule '.js' => [ "%{^#{tmplib},#{templates}}X.js.erb" ] do |t|
      File.write(t.name, WebConsole::Testing::ERBPrecompiler.new(t.source).build)
    end
  end
end

Bundler::GemHelper.install_tasks

task default: :test
