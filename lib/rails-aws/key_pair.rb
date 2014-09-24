module RailsAWS
	class KeyPair

		def initialize( branch_name )
			@branch_name = branch_name
			@ec2 = RailsAWS::EC2Client.get
		end

		def exists?
			@ec2.key_pairs[ @branch_name ].exists?
		end

		def create!
			raise "Key exists: #{@branch_name}".red unless exists?
			raise "Key Pair File exists: #{key_pair_file}".red unless File.file? key_pair_file

  		FileUtils.mkdir_p keys_dir unless File.directory?( keys_dir )
  
  		key_pair = @ec2.key_pairs.create( @branch_name )

  		File.open( key_pair_file, "wb") do |f|
  			f.write( key_pair.private_key )
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

		def keys_dir
			File.join( Rails.root, "config/keys" )
		end

		def key_pair_file
  		File.join( keys_dir, "#{@branch_name}.private_key" )
		end
	end
end
