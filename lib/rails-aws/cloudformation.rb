module RailsAWS
	class Cloudformation

		def self.outputs
			branch_name = RailsAWS.branch
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
			@branch_name = RailsAWS.branch
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

			case @type 
			when :stack
				@stack_name = clean_stack_name( @application + @branch_name )
				@stack = @cfm.stacks[ @stack_name ] 
				@rendered_file = File.join( RailsAWS.branch_dir, "cloudformation.json" )
				@template_file = File.expand_path( "../stack.json.erb", __FILE__ )
			when :domain
				@stack_name = clean_stack_name( @application + @branch_name + "domain" )
				@stack = @cfm.stacks[ @stack_name ] 
				@rendered_file = File.join( RailsAWS.branch_dir, "domain.json" )
				@template_file = File.expand_path( "../route53.json.erb", __FILE__ )
			end
		end

		def exists?
			@cfm.stacks[ @stack_name ].exists?
		end

		def delete!
			unless exists?
				msg = "Cloudformation stack does not exist: #{@stack_name}".red
				Rails.logger.info msg
				raise msg 
			end

			delete_stack
		end

		def create!
			if exists?
				msg = "Cloudformation stack exists: #{@stack_name}".red
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
			msg = "Stack: #{@stack_name} - #{@stack.status}".yellow
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

		def clean_stack_name( stack_name )
			stack_name.gsub( /(-|_)/, 'x' )
		end

		def delete_stack
			msg = "Stack: #{@stack_name}:#{@stack.status} Deleting...".green
			puts msg
			Rails.logger.info( msg )
			@stack.delete
			while @stack.exists? && @stack.status == "DELETE_IN_PROGRESS"
				msg = "Stack: #{@stack_name} Status: #{@stack.status}".yellow
				puts msg
				Rails.logger.info( msg )
				sleep( 5 )
			end

			if @stack.exists?
				msg = "Stack: #{@stack_name} Failed to Delete. Status: #{@stack.status}".red
				puts msg
				Rails.logger.info( msg )
			else
				msg = "Stack: #{@stack_name} Deleted".green
				puts msg
				Rails.logger.info( msg )
			end
		end

		def create_stack
			template = File.open( @rendered_file ).read
			@stack = @cfm.stacks.create( @stack_name, template)

			while @stack.status == "CREATE_IN_PROGRESS"
				show_stack_status
				sleep( 5 )
			end

			show_stack_status
			show_stack_events

			successful_stack?

			log_stack_outputs if @type == :stack
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

		def successful_stack?
			unless @stack.status == "CREATE_COMPLETE"
				msg = "Stack Creation FAILED: '#{@stack_name}': #{@stack.status}".red
				Rails.logger.info( msg )
				raise msg
			end
		end

		def render_erb
			Rails.logger.info "Cloudformation Template File: #{@template_file}".green

			template = File.open( @template_file ).read

			renderer = ERB.new( template, nil, '%' )

			File.open( @rendered_file, 'w' ) do |f|
				f.puts renderer.result( binding )
			end

			Rails.logger.info "Generated cloudformation: #{@rendered_file}".green
		end
	end
end
