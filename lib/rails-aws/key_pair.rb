module RailsAWS
	class KeyPair

		def self.file( branch_name )
			File.join( RailsAWS.branch_dir( branch_name ), "private.key" )
		end

		def initialize( branch_name = RailsAWS.branch )
			@branch_name = branch_name
			@ec2 = RailsAWS::EC2Client.get
		end

		def exists?
			@ec2.key_pairs[ @branch_name ].exists?
		end

		def create!
			if exists?
				msg = "Key exists: #{@branch_name}".red
				Rails.logger.fatal msg
				raise msg
			end

			if File.file? key_pair_file
				msg = "Key Pair File exists: #{key_pair_file}".red 
				Rails.logger.fatal msg
				raise msg
			end

			key_pair = @ec2.key_pairs.create( @branch_name )

			File.open( key_pair_file, "wb") do |f|
				f.write( key_pair.private_key )
			end

			unless system( "chmod 400 #{key_pair_file}" )
				msg = "Error: Unable to chmod 400 #{key_pair_file}".red
				Rails.logger.fatal msg
				raise msg
			end

			Rails.logger.info "Created KeyPair: #{@branch_name} and local file: #{key_pair_file}".green
		end

		def delete!
			status = Array.new 

			if exists?
				@ec2.key_pairs[ @branch_name ].delete
				status << "Key: #{@branch_name} deleted in AWS".green
			else
				status << "Key: #{@branch_name} didnt exist in AWS.".red
			end

			if File.file? key_pair_file
				FileUtils.rm( key_pair_file )
				status << "Key File Removed: #{key_pair_file}".green
			else
				status << "Key File does not exist: #{key_pair_file}".red
			end

			status.each do |msg|
				puts msg
				Rails.logger.info( msg )
			end
		end

		private

		def key_pair_file
			KeyPair.file( @branch_name )
		end
	end
end
