module RailsAWS
	require 'rails'
	require 'colorize'
	require 'haml'
	require 'haml-rails'
	require 'aws-sdk'

	require 'securerandom'

	require 'rails-aws/railtie'
	require 'rails-aws/ec2_client'
	require 'rails-aws/cfm_client'
	require 'rails-aws/key_pair'
	require 'rails-aws/cloudformation'
	require 'rails-aws/rds'


	def self.environment
		env = Rails.env
		raise "Support production/development only" unless %w(production development).include? env
		env
	end

	def self.snapshot_id_file
		File.join( RailsAWS.branch_dir, 'rds_snapshot_id.yml' )
	end

	def self.set_snapshot_id( snapshot_id )
		data = { :snapshot_id => snapshot_id }
		File.open( RailsAWS.snapshot_id_file, 'w' ) {|f| f.puts data.to_yaml }
	end

	def self.snapshot_id
		file = RailsAWS.snapshot_id_file
		if File.file? file
			data = YAML.load_file file
			data[:snapshot_id]
		else
			nil
		end
	end

	def self.dbpassword_file 
		File.join( RailsAWS.branch_dir, "dbpassword" )
	end

	def self.set_dbpassword
		pass_file = RailsAWS.dbpassword_file
		raise "dbpassword_file #{pass_file} exists already".red if File.file? pass_file

	  random_string = SecureRandom.hex
		File.open( pass_file, 'w' ) {|f| f.puts random_string }
		puts "Created #{pass_file}".green
	end

	def self.dbpassword
		pass_file = RailsAWS.dbpassword_file
		raise "dbpassword_file does not exist: #{pass_file}".red unless File.file? pass_file
		File.open( pass_file, 'r' ).read.chomp
	end

	def self.branch( branch = nil )
		@@branch ||= branch
		raise "Error: Branch is not set.".red if @@branch.nil?
		@@branch
	end

	def self.branch_dir
		branch_dir = File.join( Rails.root, 'config/branch', RailsAWS.branch )
  	FileUtils.mkdir_p branch_dir unless File.directory?( branch_dir )
		branch_dir
	end

	def self.branch_secret
		File.join( RailsAWS.branch_dir, 'secret' )
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
		# db_type = ActiveRecord::Base.connection.adapter_name.downcase
		config_key = "db_type_#{RailsAWS.environment}".to_sym
		db_type = RailsAWS.config( config_key )

		db_type = case db_type
          		when /^mysql/
          			:mysql
          		when /^sqlite/
          			:sqlite
          		else
          			raise "Unsupported db type: #{db_type}"
          		end
		db_type
	end

	def self.ami_id
		# from: http://cloud-images.ubuntu.com/locator/ec2/
		RailsAWS.config( :ami_id )
	end

	def self.deploy_key( options = {} )
		File.join( Rails.root, 'config/deploy_key/', "#{RailsAWS.application( options )}_id_rsa" )
	end

	def self.account_id
		RailsAWS.config( :account_id )
	end

	def self.repo_url( options = {} )
		RailsAWS.config( :repo_url, options )
	end

	def self.region
		RailsAWS.config( :region )
	end

	def self.instance_type
		RailsAWS.config( :instance_type )
	end

	def self.application( options = {} )
		repo_url = RailsAWS.repo_url( options )
		raise "Invalid format for repo_url to get application name, expecting ~= .../[application].git, #{repo_url}" unless repo_url =~ /\/[a-z0-9\-_.]+\.git$/
		return File.basename repo_url, ".*"
	end

	def self.domain_enabled?
		return false unless RailsAWS.config_hash.has_key?( 'domain' )
		return false unless RailsAWS.config_hash.has_key?( 'domain_branch' )
		return false if RailsAWS.config_hash[ 'domain' ].nil?
		return false if RailsAWS.config_hash['domain_branch'].nil?
		return true if RailsAWS.branch == RailsAWS.config_hash[ 'domain_branch' ]
		return false
	end

	def self.domain_branch
		RailsAWS.config( :domain_branch )
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