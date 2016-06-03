require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :metrics do
  desc 'Run application metrics application'
  task :run do
    system 'bundle exec rubocop lib --format html --out metrics/rubocop/report.html'
    system 'bundle exec brakeman -p lib -o metrics/brakeman/report.html'
    system 'COVERAGE=true bundle exec rspec'
    system 'bundle exec rubycritic lib --path metrics/rubycritic'
  end
end
