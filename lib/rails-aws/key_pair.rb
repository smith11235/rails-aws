module RailsAWS
	class KeyPair

		def self.file( branch_name )
  		File.join( RailsAws.branch_dir, "#{branch_name}.private_key" )
		end

		def initialize( branch_name )
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
			unless exists?
				msg = "Key does not exist: #{@branch_name}".red 
				Rails.logger.fatal( msg )
				raise msg
			end
			unless File.file? key_pair_file
				msg = "Key Pair File does not exist: #{key_pair_file}".red 
				Rails.logger.fatal( msg )
				raise msg
			end

  		@ec2.key_pairs[ @branch_name ].delete
  		FileUtils.rm( key_pair_file )

  		Rails.logger.info "Deleted KeyPair: #{@branch_name} and removed: #{key_pair_file}".green
		end

		private

		def key_pair_file
			KeyPair.file( @branch_name )
		end
	end
end
