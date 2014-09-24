namespace :aws do

	desc "Setup RailsAWS environment"
	task :setup_rails_aws => :environment do
		$ec2 = RailsAWS::EC2Client.get
	end

	desc "Create a new stack from [branch_name]"
	task :create_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?

		key_pair = ec2.key_pairs.create("mykey")
		File.open("~/.ssh/ec2", "wb") do |f|
			  f.write(key_pair.private_key)
		end
	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?
	end

	desc "Show status for all stacks"
	task :status => :setup_rails_aws do 
		status = Hash.new
		status[ :key_pairs ] = Array.new
		status[ :key_pairs ] = $ec2.key_pairs.collect do |key_pair|
			key_pair.name
		end

		puts status.to_yaml.green
	end

end
