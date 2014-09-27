module RailsAWS
	require 'rails'
	require 'colorize'
	require 'haml'
	require 'haml-rails'
	require 'aws-sdk'


	require 'rails-aws/railtie'
	require 'rails-aws/ec2_client'
	require 'rails-aws/cfm_client'
	require 'rails-aws/key_pair'
	require 'rails-aws/cloudformation'

	def self.branch_dir( branch )
		branch_dir = File.join( Rails.root, 'config/branch', branch )
  	FileUtils.mkdir_p branch_dir unless File.directory?( branch_dir )
		branch_dir
	end


	# make a hash based on region
	def self.ami_id
		# from: http://cloud-images.ubuntu.com/locator/ec2/
		"ami-8afb51e2"
	end

	# replace these with user config settings, have cheap defaults
	def self.region
		'us-east-1'
	end

	def self.instance_type
		"t2.micro"
	end

	def self.application
		"rails-aws"
	end
end