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
	end

end
