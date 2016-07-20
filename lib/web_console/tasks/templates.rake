namespace :test do
  desc "Run tests for templates"
  task templates: "templates:all"

  namespace :templates do
    task all: [ :daemonize, :npm, :rackup, :wait, :spec, :test, :kill, :exit ]
    task serve: [ :npm, :rackup ]

    workdir    = Pathname(EXPANDED_CWD).join("test/templates")
    pid_file    = Pathname(Dir.tmpdir).join("web_console.#{SecureRandom.uuid}.pid")
    html_uri    = URI.parse("http://#{ENV['IP'] || '127.0.0.1'}:#{ENV['PORT'] || 29292}/html/")
    spec_runner = 'spec_runner.html'
    test_runner = 'test_runner.html'
    rackup_opts = "--host #{html_uri.host} --port #{html_uri.port}"
    test_result = nil

    def need_to_wait?(uri)
      Net::HTTP.start(uri.host, uri.port) { |http| http.get(uri.path) }
    rescue Errno::ECONNREFUSED
      retry if yield
    end

    task :daemonize do
      rackup_opts += " -D -P #{pid_file}"
    end

    task :npm do
      Dir.chdir(workdir) { system "npm install --silent" }
    end

    task :rackup do
      Dir.chdir(workdir) { system "bundle exec rackup #{rackup_opts}" }
    end

    task :wait do
      cnt = 0
      need_to_wait?(URI.join(html_uri, spec_runner)) { sleep 1; cnt += 1; cnt < 5 }
    end

    task :spec do
      Dir.chdir(workdir) { test_result = system("./node_modules/.bin/mocha-phantomjs #{URI.join(html_uri, spec_runner)}") }
    end

    task :test do
      Dir.chdir(workdir) { test_result = system("./node_modules/.bin/mocha-phantomjs #{URI.join(html_uri, test_runner)}") }
    end

    task :kill do
      system "kill #{File.read pid_file}"
    end

    task :exit do
      exit test_result
    end
  end
end
