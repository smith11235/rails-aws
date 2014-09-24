module RailsAWS

	module CFMClient

		def self.get

			aws_key_info = YAML.load_file( 'config/aws-keys.yml' )

			ec2 = AWS::CloudFormation.new( aws_key_info )

			return ec2
		end

	end
end
