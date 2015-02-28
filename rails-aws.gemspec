# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'rails-aws/version'
 
Gem::Specification.new do |s|
  s.name        = "rails-aws"
  s.version     = RailsAWS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Michael Smith"]
  s.email       = ["smith11235@gmail.com"]
  s.homepage    = "http://github.com/smith11235/rails-aws"
  s.summary     = "The best way to manage your application's aws infrastructure"
  s.description = "RailsAWS takes care of managing robust aws stacks with local dashboard support"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "bundler"
 
  s.add_dependency "aws-sdk"
	s.add_dependency "rails"
	s.add_dependency "colorize"
	#s.add_dependency "haml"
	#s.add_dependency "haml-rails"
	s.add_dependency "capistrano"
	s.add_dependency "capistrano-bundler"
	s.add_dependency "capistrano-rails"
	s.add_dependency "capistrano-rvm"

 s.add_development_dependency 'spring-commands-rspec'
 s.add_development_dependency 'rspec'

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables  = []
  s.require_path = 'lib'
end
