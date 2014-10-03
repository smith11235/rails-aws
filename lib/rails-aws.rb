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

	def self.branch( branch = nil )
		@@branch ||= branch
		raise "Error: Branch is not set.".red if @@branch.nil?
		@@branch
	end

	def self.branch_dir( branch = nil )
		RailsAWS.branch( branch )
		branch_dir = File.join( Rails.root, 'config/branch', branch )
  	FileUtils.mkdir_p branch_dir unless File.directory?( branch_dir )
		branch_dir
	end

	def self.branch_secret
		File.join( RailsAWS.branch_dir( RailsAWS.branch ), 'secret' )
	end

	def self.config_hash( options = {} )
		options = options.reverse_merge :reset => false
		if options[:reset] || @config.nil?
			@@config ||= YAML.load_file( File.join( Rails.root, 'config/rails-aws.yml' ) )
		end
		@@config
	end

	def self.config( key, options = {} )
		RailsAWS.config_hash( options )
		@@config.fetch( key.to_s )
	end

	# in rails-aws.rb
	def self.db_type
		db_type = RailsAWS.config( 'db_type' )
		case db_type
		when /^mysql/
			:mysql
		when /^sqlite/
			:sqlite
		when /^postgresql/
			raise "Not Yet supported db type: postgresql"
		else
			raise "Unsupported db type: #{db_type}"
		end
		db_type
	end

	def self.ami_id
		# from: http://cloud-images.ubuntu.com/locator/ec2/
		RailsAWS.config( :ami_id )
	end

	def self.environment
		RailsAWS.config( :environment )
	end

	def self.deploy_key( options = {} )
		File.join( Rails.root, 'config/deploy_key/', "#{RailsAWS.config( :application, options )}_id_rsa" )
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

	def self.domain_enabled?
		return false unless RailsAWS.config_hash.has_key?( 'domain' )
		return false unless RailsAWS.config_hash.has_key?( 'domain_branch' )
		return false if RailsAWS.config_hash[ 'domain' ].nil?
		return false if RailsAWS.config_hash['domain_branch'].nil?
		return true if RailsAWS.branch == RailsAWS.config_hash['domain_branch']
		return false
	end

	def self.domain
		if RailsAWS.domain_enabled?
			return RailsAWS.config( :domain )
		else
			return "~^(.+)$"
		end
	end

	private

end