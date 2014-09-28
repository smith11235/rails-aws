module RailsAWS

	class SetupGenerator < Rails::Generators::Base
		@@files = [
			'Capfile',
			'config/deploy.rb',
			'config/deploy/development.rb'
		]

		source_root File.expand_path("../", __FILE__)

		def aws_keys_config_file
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
			yes = File.file?(file) ? ask("Do you wish to update: #{file} (y)") : 'y'
			if yes == "y"
				create_file file do
					values = Hash.new
					%w( region application repo_url deploy_key environment instance_type ).each do |key|
						values[ key ] = ask "What is the '#{key}'?"
					end
					values.to_yaml
				end
			end
		end

		def capistrano_files

			@@files.each do |file|
				yes = File.file?(file) ? ask("Do you wish to update: #{file} (y)") : 'y'
				if yes == "y"
					source = File.basename( file ) 
					directory = File.dirname( file )
					mkdir directory unless File.directory? directory
					copy_file source, file
				end
			end
		end
		
	end


end
