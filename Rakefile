# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "quapistrano"
  gem.homepage = "http://github.com/tiagoblackcode/quapistrano"
  gem.license = "MIT"
  gem.summary = %Q{Yet another recipes gem for capistrano}
  gem.description = %Q{A 'Work in Progress' gem with several recipes for capistrano, using a clean approach, delegating dawting tasks to provisioners}
  gem.email = "tiago.blackcode@gmail.com"
  gem.authors = ["Tiago Melo"]
  gem.files = FileList["[A-Z]*", "{lib, spec}/**/*", ".gitignore"]
  gem.add_dependency 'capistrano'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
#  test.libs << 'lib' << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#end

#require 'simplecov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

#task :default => :test

#require 'rdoc/task'
#Rake::RDocTask.new do |rdoc|
#  version = File.exist?('VERSION') ? File.read('VERSION') : ""
#
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title = "quapistrano-qualia #{version}"
#  rdoc.rdoc_files.include('README*')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
