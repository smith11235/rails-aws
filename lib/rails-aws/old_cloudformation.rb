module RailsAWS
	class Cloudformation

		def self.outputs
			outputs_file = Cloudformation.outputs_file
			unless File.file? outputs_file
				msg = "Missing outputs file: #{outputs_file}".red
				Rails.logger.info( msg )
				raise msg
			end
			YAML.load_file( outputs_file )
		end

		def self.outputs_file
			File.join( RailsAWS.branch_dir, "outputs.yml" )
		end

		def initialize( options = {} )
			@key_name = KeyPair.key_name
			@cfm = RailsAWS::CFMClient.get
			@ec2 = RailsAWS::EC2Client.get
			@region = RailsAWS.region
			@ami_id = RailsAWS.ami_id
			@instance_type = RailsAWS.instance_type
			@application = RailsAWS.application
			@environment = RailsAWS.environment

			options = options.reverse_merge :type => :stack
			@type = options[:type]
			raise "Invalid Type: #{@type}" unless [:stack, :domain].include? @type
			@stack = @cfm.stacks[ stack_name ] 
		end

		def stack_name
			@stack_name ||= case true
											when stack?
												@application + RailsAWS.branch
											when domain?
												@application + "domain"
											end
			@stack_name.gsub( special_chars, 'x' )
		end

		def special_chars
			/(-|_|\!|\.|\?|\*)/
		end

		def branch
			@branch ||= RailsAWS.branch
			@branch.gsub( special_chars, 'x' )
		end

		def exists?
			@cfm.stacks[ stack_name ].exists?
		end

		def delete!
			unless exists?
				msg = "Cloudformation stack does not exist: #{stack_name}".red
				Rails.logger.info msg
				raise msg 
			end

			delete_stack
		end

		def update!
			unless exists?
				msg = "Cloudformation stack does not exist: #{stack_name}".red
				Rails.logger.fatal msg
				raise msg
			end

			render_erb
			update_stack
		end

		def create!
			if exists?
				msg = "Cloudformation stack exists: #{stack_name}".red
				Rails.logger.fatal msg
				raise msg
			end

			render_erb
			create_stack
		end

		def show_stack_events( stdout = false )
			@stack.events.each do |event|
				msg = "Event: #{event.logical_resource_id} - #{event.resource_status} - #{event.resource_status_reason}"
				Rails.logger.info( msg )
				puts msg if stdout
			end
		end

		def show_stack_status
			msg = "Stack: #{stack_name} - #{@stack.status}".yellow
			puts msg
			Rails.logger.info( msg )
			@stack.resources.each do |resource|
				msg = "#{resource.resource_type}: #{resource.resource_status} # #{resource.resource_status_reason}"
				puts msg
				if resource.resource_type == "AWS::EC2::Instance" && resource.resource_status == "CREATE_COMPLETE"
					instance = @ec2.instances[ resource.physical_resource_id ]
					console_output = instance.console_output
					unless console_output.nil?
						tailing = console_output
						puts "vvvvvvvvvvvvvvvvvv Console Output vvvvvvvvvvvvvvvv".yellow
						puts "Class: #{tailing.class} and size: #{tailing.size}".red
						tailing = tailing.split( /\n/ )
						puts "Class: #{tailing.class} and size: #{tailing.size}".red
						if tailing.size > 50
							tailing = tailing[ (tailing.size - 50)..tailing.size ]
						end
						puts tailing.to_yaml.green
						puts "^^^^^^^^^^^^^^^^^^ Console Output ^^^^^^^^^^^^^^^^".yellow
					end
				end
			end
		end

		private 

		def delete_stack
			msg = "Stack: #{stack_name}:#{@stack.status} Deleting...".green
			puts msg
			Rails.logger.info( msg )
			@stack.delete
			while @stack.exists? && @stack.status == "DELETE_IN_PROGRESS"
				msg = "Stack: #{stack_name} Status: #{@stack.status}".yellow
				puts msg
				Rails.logger.info( msg )
				sleep( 5 )
			end

			if @stack.exists?
				msg = "Stack: #{stack_name} Failed to Delete. Status: #{@stack.status}".red
				puts msg
				Rails.logger.info( msg )
			else
				msg = "Stack: #{stack_name} Deleted".green
				puts msg
				Rails.logger.info( msg )
			end
		end

		def update_stack
			@stack = @cfm.stacks[ stack_name ]
			@stack.update( :template => template )
			track_stack( "UPDATE_IN_PROGRESS", "UPDATE_COMPLETE" )
		end

		def template
			File.open( rendered_file ).read
		end

		def create_stack
			@stack = @cfm.stacks.create( stack_name, template)
			track_stack( "CREATE_IN_PROGRESS", "CREATE_COMPLETE" )
		end

		def track_stack( starting_status, ending_status )
			puts "Starting stack status: #{starting_status}"
			while @stack.status == starting_status
				show_stack_status
				sleep( 5 )
			end

			show_stack_status
			show_stack_events

			unless @stack.status == ending_status
				msg = "Stack Creation FAILED, expected(#{ending_status}), Received: '#{stack_name}': #{@stack.status}".red
				Rails.logger.info( msg )
				raise msg
			end

			log_stack_outputs if stack?
		end

		def log_stack_outputs
			outputs_file = Cloudformation.outputs_file

			outputs = Hash.new
			@stack.outputs.each do |output|
				outputs[ output.key ] = output.value
			end

			Rails.logger.info( outputs.to_yaml.green )
			puts outputs.to_yaml.green

			File.open( outputs_file, 'w' ) do |f|
				f.puts outputs.to_yaml
			end
		end


		def render_erb
			Rails.logger.info "Cloudformation Template File: #{template_file}".green

			template = File.open( template_file ).read

			renderer = ERB.new( template, nil, '%' )

			File.open( rendered_file, 'w' ) do |f|
				f.puts renderer.result( binding )
			end

			Rails.logger.info "Generated cloudformation: #{rendered_file}".green
		end
	end
end
