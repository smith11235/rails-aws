require 'rails-aws'

module RailsAWS

	class SetupGenerator < Rails::Generators::Base
		@@files = [
			'Capfile',
			'config/deploy.rb',
			'config/deploy/development.rb'
		]

		source_root File.expand_path("../", __FILE__)

		def aws_keys_config_file
			RailsAWS::EC2Client.get
			file = "config/aws-keys.yml"
			yes = File.file?(file) ? ask("Do you wish to update: #{file} (y)") : 'y'
			if yes == "y"
				create_file file do
					keys = [ :access_key_id, :secret_access_key ]
					values = Hash.new
					values[:region] = RailsAWS.region
					keys.each do |key|
						values[key] = ask "What is the '#{key}'?" 
					end
					values.to_yaml
				end
			end
		end


		def rails_aws_settings
			file = "config/rails-aws.yml"
			yes = if File.file?(file)
							defaults = RailsAWS.config_hash( :reset => true )
							ask("Do you wish to update: #{file} (y)") 
						else
							defaults = {}
							'y'
						end

			if yes == "y"
				create_file file do
					values = Hash.new

					%w(repo_url).each do |key|
						values[ key ] = ask "What is the '#{key}'?"
					end
					values[ 'environment' ] = "development"
					values[ 'instance_type' ] = "t2.micro"
					values[ 'region' ] = 'us-east-1'
					values[ 'ami_id' ] = "ami-8afb51e2"

					repo_url = values[ 'repo_url' ]
					#raise "Unknown repo_url,\nexpecting [user]@[domain]:[project|accout]\nlike git@github.com:smith11235/rails-aws.git".red
					application = File.basename repo_url
					values[ 'application' ] = application

					values.to_yaml
				end
			end
		end

		def deploy_key
			file = RailsAWS.deploy_key( :reset => true )
			yes = File.file?(file) ? ask("Do you wish to update: #{file} (y)") : 'y'
			if yes == "y"
				deploy_dir = File.dirname file
				FileUtils.mkdir deploy_dir unless File.directory? deploy_dir
				system( "ssh-keygen -t rsa -f #{file}" )
				system( "vim #{File.join( Rails.root, 'public/git_deploy_keys.md' )}" )
				puts "Deploy Key - Add Contents to Repository: #{file}".green
				puts `cat #{file}.pub`.yellow
			end
		end

		def capistrano_files

			@@files.each do |file|
				yes = File.file?(file) ? ask("Do you wish to update: #{file} (y)") : 'y'
				if yes == "y"
					source = File.basename( file ) 
					directory = File.dirname( file )
					FileUtils.mkdir directory unless File.directory? directory
					copy_file source, file
				end
			end
		end
		
		def gitignore
			ignore_file = File.join Rails.root, '.gitignore'
			%w(
      /config/aws-keys.yml
      /config/branch/*/private.key
      /config/deploy_key
			).each do |ignore|
				system( "echo #{ignore} >> #{ignore_file}" )
			end
		end

		def git_deploy_keys_doc
			copy_file 'git_deploy_keys.md', File.join( Rails.root,'public' )
		end

	end

end
