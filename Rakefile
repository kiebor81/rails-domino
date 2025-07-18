# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test" # Add the test directory to the load path
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

task default: :test
