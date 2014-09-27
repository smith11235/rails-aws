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
	def self.config( key )
		@config ||= YAML.load_file( File.join( Rails.root, 'config/rails-aws.yml' ) )
		@config.fetch( key )
	end

	def self.environment
		RailsAWS.config( :environment )
	end

	def self.deploy_key
		RailsAWS.config( :deploy_key )
	end

	def self.repo_url
		RailsAWS.config( :repo_url )
	end

	def self.region
		RailsAWS.config( :region )
	end

	def self.instance_type
		RailsAWS.config( :instance_type )
	end

	def self.application
		RailsAWS.config( :application )
	end
end