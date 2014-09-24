namespace :aws do

	desc "Setup RailsAWS environment"
	task :setup_rails_aws => :environment do
		$ec2 = RailsAWS::EC2Client.get
	end

	desc "Create a new stack from [branch_name]"
	task :create_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]
		raise "Key already exists: #{branch_name}".red if $ec2.key_pairs[ branch_name ].exists?
		FileUtils.mkdir_p "config/keys" 

		key_pair = $ec2.key_pairs.create( branch_name )

		key_pair_file = "config/keys/#{branch_name}.private_key"
		File.open( key_pair_file, "wb") do |f|
			f.write(key_pair.private_key)
		end
		puts "Created KeyPair: #{branch_name} and local file: #{key_pair_file}".green

	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]
		raise "Key does not exist: #{branch_name}".red unless $ec2.key_pairs[ branch_name ].exists?
		$ec2.key_pairs[ branch_name ].delete
		key_pair_file = "config/keys/#{branch_name}.private_key"
		FileUtils.rm( key_pair_file )
		puts "Deleted KeyPair: #{branch_name} and removed: #{key_pair_file}".green

	end

	desc "Show status for all stacks"
	task :status => :setup_rails_aws do 
		status = Hash.new
		status[ :key_pairs ] = $ec2.key_pairs.collect do |key_pair|
			key_pair.name
		end

		puts status.to_yaml.green
	end

end
