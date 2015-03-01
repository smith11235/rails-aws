require 'rails-aws'

module RailsAws

  class SetupGenerator < Rails::Generators::Base

    source_root File.expand_path("../", __FILE__)


    def rails_aws_settings
      file = "config/rails-aws.yml"
      # defaults = RailsAWS.config_hash( :reset => true )

      if modify? file, :confirm => true, :suggested => "Update carefully".yellow
        values = Hash.new
        values[ 'repo_url' ] = ask "What is your rails application git clone 'repo_url'?"
        values[ 'account_id' ] = ask "What is your amazon web services 'account_id'?"

        puts "Sqlite db's are cheaper to run, but lower performance for multi-user/non-trivial applications"
        puts "Development environment is by default sqlite.  You can modify this afterwards"
        prod_mysql = ask 'Do you wish to run a mysql server for your production environments (y)'
        prod_type = if prod_mysql == 'y'
                      "mysql"
                    else
                      "sqlite" 
                    end
        values[ 'db_type_production' ] = prod_type
        values[ 'db_type_development' ] = 'sqlite'

        # defaults, user can setup afterwards
        values[ 'domain' ] = nil
        values[ 'domain_branch' ] = nil

        # default supported values
        values[ 'instance_type' ] = "t2.micro"
        values[ 'region' ] = 'us-east-1'
        values[ 'ami_id' ] = "ami-8afb51e2"

        create_file file do
          values.to_yaml
        end
      end
    end

    def database_config_file
      file = "config/database.yml"
      if modify? file, :suggested => "Safe to update, use the rails-aws provided config".green

        copy_file File.basename( file ), file

        RailsAWS.config_hash( :reset => true )
        prod_type = RailsAWS.db_type
        sed_cmd = "sed -i 's/production_type/#{prod_type}/' #{file}"
        raise "Unable to set production type: #{sed_cmd}" unless system( sed_cmd )
        puts "Set production database to: #{prod_type}"
      end
    end

    def aws_keys_config_file
      file = "config/aws-keys.yml"
      if modify? file, :suggested => "Safe to update... dont lose your secret key though".yellow
        create_file file do
          keys = [ :access_key_id, :secret_access_key ]
          values = Hash.new
          keys.each do |key|
            values[key] = ask "What is the '#{key}'?" 
          end
          RailsAWS.config_hash( :reset => true )
          values[:region] = RailsAWS.region
          values.to_yaml
        end
      end
    end

    def deploy_key
      file = RailsAWS.deploy_key( :reset => true )
      if modify? file, :suggested => "Safe to update... requires git remote repository changes".yellow
        deploy_dir = File.dirname file
        FileUtils.mkdir deploy_dir unless File.directory? deploy_dir
        system( "ssh-keygen -t rsa -f #{file}" )
        system( "vim #{File.join( Rails.root, 'public/git_deploy_keys.md' )}" )
        puts "Deploy Key - Add Contents to Repository: #{file}".green
        puts `cat #{file}.pub`.yellow
      end
    end

    def capistrano_files

      files = [
        'Capfile',
        'config/deploy.rb',
        'config/deploy/development.rb',
        'config/deploy/production.rb'
      ]
      files.each do |file|
        if modify? file, :suggested => "Safe to update".green
          source = File.basename( file ) 
          directory = File.dirname( file )
          FileUtils.mkdir directory unless File.directory? directory
          copy_file source, file
        end
      end
    end

    def gitignore
      ignore_file = File.join Rails.root, '.gitignore'
      if modify? ignore_file, :suggested => "Ensure you add these ignores in".green
        %w(
        /config/aws-keys.yml
        /config/branch/*/private.key
        /config/branch/*/secret
        /config/deploy_key
        ).each do |ignore|
          system( "echo #{ignore} >> #{ignore_file}" )
        end
      end
    end


    def config_secrets
      file = 'config/secrets.yml'
      if modify? file, :suggested => "Safe to update".green
        copy_file 'secrets.yml', File.join( Rails.root, file )
      end
    end

    private

    def modify?( file, opts = {} )
      opts = opts.reverse_merge( :confirm => false, :suggested => nil  )
      exists_already = File.file?(file)
      answer = if exists_already
                 puts
                 puts "---".green
                 puts "File: #{file}"
                 puts "Suggested: #{opts[:suggested]}" if opts[:suggested]
                 ask("Do you wish to modify (y)".yellow)  == 'y'
               else
                 true
               end
      answer = if exists_already && answer && opts[:confirm]
                 ask( "Are you sure you wish to modify (Y)".red ) == 'Y'
               else
                 answer
               end
      return answer
    end
  end


end
