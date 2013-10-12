require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

desc "Run dev binary"
task :run do
  exec "ruby -I lib ./bin/server_builder"
end
