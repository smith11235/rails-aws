namespace :aws do


	desc "Create a new stack from [branch_name]"
	task :create_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		key_pair = RailsAWS::KeyPair.new( branch_name )
		cloudformation = RailsAWS::Cloudformation.new( branch_name )

		key_pair.create!
		cloudformation.create!
	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		failed = false
		begin
			cloudformation = RailsAWS::Cloudformation.new( branch_name )
			cloudformation.delete!
		rescue 
			failed = true
			msg = "Failed to delete cloudformation, moving on...".red
			puts msg
			Rails.logger.info( msg )
		end

		begin
			key_pair = RailsAWS::KeyPair.new( branch_name )
			key_pair.delete!
		rescue 
			failed = true
			msg = "Failed to delete key_pair, moving on...".red
			puts msg
			Rails.logger.info( msg )
		end

		if failed
			msg = "delete_stack[#{branch_name}] FAILED".red
			Rails.logger.info( msg )
			raise msg 
		end
		msg = "delete_stack[#{branch_name}] successful".green
		Rails.logger.info( msg )
		puts msg
	end

	desc "Show status for all stacks"
	task :status => :environment do 
		status = Hash.new

		status[ :key_pairs ] = RailsAWS::EC2Client.new().key_pairs.collect do |key_pair|
			key_pair.name
		end

		status[ :local_keys ] = Dir.glob( File.join( Rails.root, 'config/keys/*' ) )

		status[ :cloudformation ] = Hash.new
		RailsAws::CFMClient.new().stacks.each do |stack|
			status[ :cloudformation ][ stack.name ] = stack.status
		end

		puts status.to_yaml.green
	end

	desc "Show stack status, useful for monitoring"
	task :stack_status, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]
		cf = RailsAWS::Cloudformation.new( branch_name )
		cf.show_stack_status
		cf.show_stack_events( true )
	end

	desc "Detail report for all infrastructure in account"
	task :details => :environment do

	end
end
