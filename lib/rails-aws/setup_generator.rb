module RailsAWS

	class SetupGenerator < Rails::Generators::Base

		def aws_keys_config_file
			create_file "config/aws-keys.yml" do
				keys = [ :access_key_id, :secret_access_key ]
				values = Hash.new
				values[:region] = RailsAWS.region
				keys.each do |key|
					values[key] = ask "What is the '#{key}'?" 
				end
				values.to_yaml
			end

		end

		def rails_aws_settings
			create_file "config/rails-aws.yml" do
				values = Hash.new
				%w( region application repo_url deploy_key environment instance_type ).each do |key|
					values[ key ] = ask "What is the '#{key}'?"
				end

				values.to_yaml
			end
		end
	end

end
