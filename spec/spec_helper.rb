if ENV['COVERAGE']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'pry-byebug'
require 'mongoid'

require 'rspec'
require 'mongoid/rspec'
require 'factory_girl'
require 'database_cleaner'
require 'mongoid_followit'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each   {|f| require f}
Dir[File.dirname(__FILE__) + '/factories/**/*.rb'].each {|f| require f}

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
