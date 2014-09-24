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

	def self.region
		'us-east-1'
	end

end