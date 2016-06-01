$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry-byebug'
require 'mongoid'

require 'rspec'
require 'mongoid/rspec'
require 'factory_girl'
require 'database_cleaner'
require 'mongoid_followit'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each   {|f| require f}
Dir[File.dirname(__FILE__) + '/factories/**/*.rb'].each {|f| require f}

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    coverage_dir 'metrics/simplecov'

    add_filter 'bin'
    add_filter 'metrics'
    add_filter 'spec'

    add_group 'Library', 'lib'
  end
end

Mongo::Logger.logger.level = ::Logger::FATAL
Mongoid.configure do |config|
  config.connect_to("mongoid_followit_test")
end

RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
