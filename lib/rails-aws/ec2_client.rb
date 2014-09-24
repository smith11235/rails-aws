module RailsAWS

	module EC2Client

		def self.get

			aws_key_info = YAML.load_file( 'config/aws-keys.yml' )

			ec2 = AWS::EC2.new( aws_key_info )

			return ec2
		end

	end
end
