module RailsAWS
	class Cloudformation

		def initialize( branch_name )
			@branch_name = branch_name

			@cfm = RailsAWS::CFMClient.get
			@ec2 = RailsAWS::EC2Client.get

			@template_file = File.expand_path( "../stack.json.erb", __FILE__ )

			@output_dir = File.join( Rails.root, 'cloudformation' )

			@region = RailsAWS.region
			raise "update ami handling".red unless @region ==	"us-east-1"
			@ami_id = "ami-8afb51e2"
			# from: http://cloud-images.ubuntu.com/locator/ec2/
			@instance_type = "t2.micro"
			@name = "partyshuffle-#{@branch_name}"

			@stack = @cfm.stacks[ @branch_name ] 
		end

		def exists?
			@cfm.stacks[ @branch_name ].exists?
		end

		def delete!
			unless exists?
				msg = "Cloudformation stack does not exist: #{@branch_name}".red
				Rails.logger.info msg
				raise msg 
			end

			delete_stack
		end

		def create!
			if exists?
				msg = "Cloudformation stack exists: #{@branch_name}".red
				Rails.logger.fatal msg
				raise msg
			end

			render_erb

			create_stack
		end

		def show_stack_status
			msg = "Stack: #{@branch_name} - #{@stack.status}".yellow
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
			msg = "Stack: #{@branch_name}:#{@stack.status} Deleting...".green
			puts msg
			Rails.logger.info( msg )
			@stack.delete
			while @stack.exists? && @stack.status == "DELETE_IN_PROGRESS"
				msg = "Stack: #{@branch_name} Status: #{@stack.status}".yellow
				puts msg
				Rails.logger.info( msg )
				sleep( 5 )
			end

			if @stack.exists?
				msg = "Stack: #{@branch_name} Failed to Delete. Status: #{@stack.status}".red
				puts msg
				Rails.logger.info( msg )
			else
				msg = "Stack: #{@branch_name} Deleted".green
				puts msg
				Rails.logger.info( msg )
			end
		end

		def create_stack
			template = File.open( rendered_file ).read
			@stack = @cfm.stacks.create( @branch_name, template)
			while @stack.status == "CREATE_IN_PROGRESS"
				show_stack_status
				sleep( 5 )
			end
			Rails.logger.info( "Post CREATE_IN_PROGRESS Stack State: #{@stack.status}" )
			@stack.events.each do |event|
				msg = "Event: #{event.logical_resource_id} - #{event.resource_status} - #{event.resource_status_reason}"
				Rails.logger.info( msg )
			end
			if @stack.status == "CREATE_COMPLETE"
				@stack.outputs.each do |output|
					msg = "Output: #{output.key}: #{output.value} # #{output.description}".green
					Rails.logger.info( msg )
					puts msg
				end
			else 
				msg = "Stack Creation Error: Stack '#{@branch_name}' has status: #{@stack.status}".red
				Rails.logger.info( msg )
				raise msg
			end
		end


		def rendered_file
			File.join( @output_dir, "#{@branch_name}.json" )
		end

		def render_erb
			FileUtils.mkdir_p( @output_dir ) unless File.directory?( @output_dir )
			Rails.logger.info "Cloudformation Template File: #{@template_file}".green

			template = File.open( @template_file ).read

			renderer = ERB.new( template, nil, '%' )

			File.open( rendered_file, 'w' ) do |f|
				f.puts renderer.result( binding )
			end

			Rails.logger.info "Generated cloudformation: #{rendered_file}".green
		end
	end
end
