require 'rspec/core'
require 'hatchet'
require 'fileutils'
require 'hatchet'
require 'rspec/retry'
require 'date'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.filter_run focused: true unless ENV['IS_RUNNING_ON_TRAVIS']
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, focused: true
  config.full_backtrace      = true
  config.verbose_retry       = true # show retry status in spec process
  config.default_retry_count = 2 if ENV['IS_RUNNING_ON_TRAVIS'] # retry all tests that fail again

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  #config.mock_with :none
end

def git_repo
  "https://github.com/heroku/heroku-buildpack-metrics.git"
end

def init_app(app)
  app.setup!
end

def successful_body(app, options = {})
  retry_limit = options[:retry_limit] || 50
  path = options[:path] ? "/#{options[:path]}" : ''
  Excon.get("http://#{app.name}.herokuapp.com#{path}", :idempotent => true, :expects => 200, :retry_limit => retry_limit).body
end

ReplRunner.register_commands(:console)  do |config|
  config.terminate_command "exit"          # the command you use to end the 'rails console'
  config.startup_timeout 60                # seconds to boot
  config.return_char "\n"                  # the character that submits the command
  config.sync_stdout "STDOUT.sync = true"  # force REPL to not buffer standard out
end
