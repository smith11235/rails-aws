module RailsAWS

	class RDS

		def initialize
			aws_key_info = YAML.load_file( 'config/aws-keys.yml' )

			@client = AWS::RDS.new( aws_key_info )

		end

		def available_info

			info = { :no_current_db => Array.new }

			@client.db_instances.each do |instance|
				arn = "arn:aws:rds:#{RailsAWS.region}:#{RailsAWS.account_id}:db:#{instance.id}"
				response = @client.client.list_tags_for_resource( :resource_name => arn )
				tag_name = nil
				response[:tag_list].each do |tag|
					if tag[:key] == "Name"
						tag_name = tag[:value]
					end
				end
				info[ instance.id ] = { :name => tag_name, :snapshots => [] }
			end

			@client.db_snapshots.each do |instance|
				if info.has_key? instance.db_instance_id
					info[ instance.db_instance_id ][ :snapshots ] << { :id => instance.id, :created_at => instance.created_at }
				else
					info[ :no_current_db ] << { :id => instance.id, :db_id => instance.db_instance_id, :created_at => instance.created_at }
				end
			end

			puts "Available RDS db and snapshots".green
			puts info.to_yaml

		end
	end


end
