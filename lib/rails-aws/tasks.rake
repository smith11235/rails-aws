namespace :aws do


	desc "Create a new stack from [branch_name]"
	task :stack_create, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		RailsAWS.branch( branch_name )

		key_pair = RailsAWS::KeyPair.new

		if RailsAWS.db_type != :sqlite
			db_password_file = RailsAWS.dbpassword_file 
			unless File.file? db_password_file
				RailsAWS.set_dbpassword
			else
				puts "Reusing previously created dbpassword: #{db_password_file}".yellow
			end
		end

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

		cloudformation = RailsAWS::Cloudformation.new( :type => :domain )

		cloudformation.create!
	end

	desc "Remove a specified domain to your stack for that branch"
	task :domain_delete, [:branch_name] => :environment do |t,args|
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]

		RailsAWS.branch( branch_name )

		raise "Domain is not enabled, must have 'domain' and 'domain_branch' config with this branch specified" unless RailsAWS.domain_enabled?

		cloudformation = RailsAWS::Cloudformation.new( :type => :domain )

		cloudformation.delete!
	end

	desc "Login to ec2"
	task :stack_login, [:branch_name] => :environment do |t,args|
		branch_name = args[:branch_name]
		raise "Missing branch name".red if branch_name.nil?
		RailsAWS.branch( branch_name )

		ip = RailsAWS::Cloudformation.outputs.fetch "IP"
		login_cmd = "ssh -i #{RailsAWS::KeyPair.file} deploy@#{ip}"
		system( login_cmd )
	end

	def cap_cmd( task )
		cmd_prefix = "cap"
		vars = {
  		:branch => RailsAWS.branch,
  		:branch_secret => RailsAWS.branch_secret,
  		:ipaddress => RailsAWS::Cloudformation.outputs.fetch("IP"),
  		:key_file => RailsAWS::KeyPair.file,
  		:repo_url => RailsAWS.repo_url,
  		:application => RailsAWS.application,
  		:deploy_key => RailsAWS.deploy_key,
  		:rails_env => RailsAWS.environment
		}

		if RailsAWS.db_type != :sqlite
			vars[ :dbhost ] = RailsAWS::Cloudformation.outputs.fetch( "DBHOST" )
			vars[ :dbpassword ] = RailsAWS.dbpassword
		end

		vars.each do |key,value|
			cmd_prefix << " #{key}='#{value}' "
		end

		cmd = "#{cmd_prefix} #{RailsAWS.environment} #{task}"

		puts "Executing: #{cmd}".green
		unless system( cmd )
			msg = "Failed Executing: #{cmd}".red
			Rails.logger.info( msg )
			raise msg
		end
	end

	def website
		puts "Website: " + RailsAWS::Cloudformation.outputs.fetch("WebsiteURL")
	end

	desc "Cap Deploy This Stack"
	task :cap_deploy, [:branch_name] => :environment do |t,args|
		branch_name = args[:branch_name]
		raise "Missing branch name".red if branch_name.nil?
		RailsAWS.branch( branch_name )

		branch_secret = RailsAWS.branch_secret

		cmd = "rake secret > #{branch_secret}"
		raise "Unable to generate secret to: #{branch_secret}" unless system( cmd )
		raise "Missing secret file: #{branch_secret}" unless File.file? branch_secret
		
		%w(deploy:publish_deploy_key deploy deploy:publish_secret deploy:restart).each do |task|
			cap_cmd( task )
		end
		puts "Capistrano Deployment Successful".green
		website
	end

	desc "Cap Deploy This Stack"
	task :cap_task, [:branch_name,:task] => :environment do |t,args|
		branch_name = args[:branch_name]
		raise "Missing branch name".red if branch_name.nil?
		RailsAWS.branch( branch_name )
		cap_cmd( args[:task] )
		website
	end

	desc "Delete a stack from [branch_name]"
	task :stack_delete, [:branch_name,:no_error] => :environment do |t,args|
		args.with_defaults :no_error => false
		raise "Missing branch name".red if args[:branch_name].nil?
		branch_name = args[:branch_name]
		RailsAWS.branch( branch_name ) 
		failed = false
		begin
			cloudformation = RailsAWS::Cloudformation.new( )
			cloudformation.delete!
		rescue => exception
			failed = true
			msg = "#{exception.inspect}\n#{exception.message.red}\nFailed to delete cloudformation, #{'moving on...'.yellow}"
			puts msg
			Rails.logger.info( msg )
		end

		begin
			key_pair = RailsAWS::KeyPair.new( )
			key_pair.delete!
		rescue => exception
			failed = true
			msg = "#{exception.inspect}\n#{exception.message.red}\nFailed to delete cloudformation, #{'moving on...'.yellow}"
			puts msg
			Rails.logger.info( msg )
		end

		if failed
			msg = "delete_stack[#{branch_name}] FAILED".red
			Rails.logger.info( msg )
			if args[:no_error] == false
				raise msg 
			end
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

		status[ :local_keys ] = Dir.glob( File.join( Rails.root, 'config/branch/*/private.key' ) )

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
		RailsAWS.branch( branch_name )
		cf = RailsAWS::Cloudformation.new 
		cf.show_stack_status
		cf.show_stack_events( true )
		puts RailsAWS::Cloudformation.outputs.to_yaml
	end

	desc "Detail report for all infrastructure in account"
	task :details => :environment do

	end
end
