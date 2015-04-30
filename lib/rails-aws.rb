module RailsAws

  require 'rails'
  require 'colorize'
  require 'aws-sdk'
  require 'i18n'
  require 'securerandom'

  require 'rails-aws/railtie'
  require 'rails-aws/config'
  require 'rails-aws/stack_builder'
  require 'rails-aws/key_pair'
  require 'rails-aws/cloudformation'

  # TODO: remove me
  #require 'rails-aws/rds'

  def self.aws_init
    aws_key_info = YAML.load_file('config/aws-keys.yml')
    aws_key_info.each do |key,value|
      ENV[key] = value
    end
  end

  def self.ec2_client
    RailsAws.aws_init
    AWS::EC2.new
  end

  def self.cfm_client
    RailsAws.aws_init
    AWS::CloudFormation.new
  end

  def t(key, options={})
    I18n.t(key, options)
  end

  def l(key, options={})
    I18n.l(key, options)
  end

  def self.logger(message)
    puts message
    Rails.logger.info "RailsAws: #{message}"
  end

  def logger(message)
    RailsAws.logger(message)
  end

=begin
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

  def self.branch_secret
    File.join( RailsAWS.branch_dir, 'secret' )
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
=end

  private

end