namespace :aws do

	desc "Setup RailsAWS environment"
	task :setup_rails_aws => :environment do
		$ec2 = RailsAWS::EC2Client.get
		$cfm = RailsAWS::CFMClient.get
	end

	desc "Create a new stack from [branch_name]"
	task :create_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		key_pair = RailsAWS::KeyPair.new( branch_name )
		raise "Key already exists: #{branch_name}".red if key_pair.exists? 

		cloudformation = RailsAWS::Cloudformation.new( branch_name )
		raise "Cloudformation stack exists: #{branch_name}".red if cloudformation.exists?

		key_pair.create!
	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		cloudformation = RailsAWS::Cloudformation.new( branch_name )
		# cloudformation.delete!

		key_pair = RailsAWS::KeyPair.new( branch_name )
		key_pair.delete!
	end

	desc "Show status for all stacks"
	task :status => :setup_rails_aws do 
		status = Hash.new

		status[ :key_pairs ] = $ec2.key_pairs.collect do |key_pair|
			key_pair.name
		end

		status[ :cloudformation ] = Hash.new
		$cfm.stacks.collect do |stack|
			status[ :cloudformation ][ stack.name ] = stack.status
		end

		puts status.to_yaml.green
	end

end
