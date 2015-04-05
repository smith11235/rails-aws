module RailsAws
	class KeyPair
    include RailsAws

    def initialize
      @config = RailsAws::Config.new
			@ec2 = RailsAws.ec2_client
		end

    def key_file
      "config/aws-stacks/#{@config.current_stack_name}.private_key"
    end

    def key_name
      @config.current_stack_name
    end

		def exists?
			@ec2.key_pairs[key_name].exists?
		end

		def create
			key_pair = @ec2.key_pairs.create(key_name)

			File.open(key_file, "wb") do |f|
				f.write key_pair.private_key
			end

			unless system("chmod 400 #{key_file}")
        raise t("key_pair.errors.unable_to_set_security", key_file: key_file)
			end
		end

		def delete
		  @ec2.key_pairs[key_name].delete if exists?
		end

		private

	end
end
