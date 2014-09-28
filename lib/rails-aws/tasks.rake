namespace :aws do


	desc "Create a new stack from [branch_name]"
	task :stack_create, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		RailsAWS.branch( branch_name )

		key_pair = RailsAWS::KeyPair.new
		cloudformation = RailsAWS::Cloudformation.new

		key_pair.create!
		cloudformation.create!
	end

	desc "Assign a specified domain to your stack for that branch"
	task :domain_create, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		RailsAWS.branch( branch_name )

		raise "Domain is not enabled, must have 'domain' and 'domain_branch' config with this branch specified" unless RailsAWS.domain_enabled?

		cloudformation = RailsAWS::Cloudformation.new( branch_name, :type => :domain )

		cloudformation.create!
	end

	desc "Remove a specified domain to your stack for that branch"
	task :domain_delete, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		RailsAWS.branch( branch_name )

		raise "Domain is not enabled, must have 'domain' and 'domain_branch' config with this branch specified" unless RailsAWS.domain_enabled?

		cloudformation = RailsAWS::Cloudformation.new( branch_name, :type => :domain )

		cloudformation.delete!
	end

	desc "Login to ec2"
	task :stack_login, [:branch_name] => :environment do |t,args|
		branch_name = args[:branch_name]
		raise "Missing branch name".red if branch_name.nil?
		ip = RailsAWS::Cloudformation.outputs(branch_name).fetch "IP"
		login_cmd = "ssh -i #{RailsAWS::KeyPair.file( branch_name )} deploy@#{ip}"
		system( login_cmd )
	end

	def cap_cmd( branch_name, task )
		cmd_prefix = "cap"
		cmd_prefix << " branch=#{branch_name}"
		cmd_prefix << " ipaddress=#{RailsAWS::Cloudformation.outputs(branch_name).fetch("IP")}"
		cmd_prefix << " key_file=#{RailsAWS::KeyPair.file( branch_name )}"

		cmd_prefix << " repo_url=#{RailsAWS.repo_url}"
		cmd_prefix << " application=#{RailsAWS.application}"
		cmd_prefix << " deploy_key=#{RailsAWS.deploy_key}"
		cmd_prefix << " rails_env=#{RailsAWS.environment}"

		cmd_prefix << " #{RailsAWS.environment} " # environment
		cmd = cmd_prefix + task

		puts "Executing: #{cmd}".green
		unless system( cmd )
			msg = "Failed Executing: #{cmd}".red
			Rails.logger.info( msg )
			raise msg
		end
	end

	def website( branch_name )
		puts "Website: " + RailsAWS::Cloudformation.outputs(branch_name).fetch("WebsiteURL")
	end

	desc "Cap Deploy This Stack"
	task :cap_deploy, [:branch_name] => :environment do |t,args|
		branch_name = args[:branch_name]
		raise "Missing branch name".red if branch_name.nil?
 		# removed: deploy:start_rails_server
		%w(deploy:publish_deploy_key deploy deploy:generate_secret).each do |task|
			cap_cmd( branch_name, task )
		end
		puts "Capistrano Deployment Successful".green
		website( branch_name )
	end

	desc "Start Rails"
	task :cap_start, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		cap_cmd( branch_name, 'deploy:start_rails_server' )
		website( branch_name )
	end

	desc "Delete a stack from [branch_name]"
	task :stack_delete, [:branch_name] => :environment do |t,args|
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

		status[ :key_pairs ] = RailsAWS::EC2Client.get.key_pairs.collect do |key_pair|
			key_pair.name
		end

		status[ :local_keys ] = Dir.glob( File.join( Rails.root, 'config/keys/*' ) )

		status[ :cloudformation ] = Hash.new
		RailsAWS::CFMClient.get.stacks.each do |stack|
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
		puts RailsAWS::Cloudformation.outputs( branch_name ).to_yaml
	end

	desc "Detail report for all infrastructure in account"
	task :details => :environment do

	end
end
