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
		cloudformation = RailsAWS::Cloudformation.new( branch_name )

		key_pair.create!
		cloudformation.create!
	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :setup_rails_aws do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		failed = false
		begin
			cloudformation = RailsAWS::Cloudformation.new( branch_name )
			cloudformation.delete!
		rescue 
			failed = true
			Rails.logger.info( "Failed to delete cloudformation, moving on...".red )
		end

		begin
			key_pair = RailsAWS::KeyPair.new( branch_name )
			key_pair.delete!
		rescue 
			failed = true
			Rails.logger.info( "Failed to delete key_pair, moving on...".red )
		end

		if failed
			raise "Something failed, check logs".red
		end
	end

	desc "Show status for all stacks"
	task :status => :setup_rails_aws do 
		status = Hash.new

		status[ :key_pairs ] = $ec2.key_pairs.collect do |key_pair|
			key_pair.name
		end

		status[ :local_keys ] = Dir.glob( File.join( Rails.root, 'config/keys/*' ) )

		status[ :cloudformation ] = Hash.new
		$cfm.stacks.collect do |stack|
			status[ :cloudformation ][ stack.name ] = stack.status
		end

		puts status.to_yaml.green
	end

	desc "Detail report for all infrastructure in account"
	task :details => :environment do

	end
end
