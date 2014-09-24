module RailsAWS
	class Cloudformation

		def initialize( branch_name )
			@branch_name = branch_name

			@cfm = RailsAWS::CFMClient.get

			@template_file = File.expand_path( "../stack.json.erb", __FILE__ )

			@output_dir = File.join( Rails.root, 'cloudformation' )

			@region = RailsAWS.region
			raise "update ami handling".red unless @region ==	"us-east-1"
			@ami_id = "ami-22ed474a"
			# from: http://cloud-images.ubuntu.com/locator/ec2/
			@instance_type = "t2.micro"
			@name = "partyshuffle-#{@branch_name}"
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
			@cfm.stacks[@branch_name].delete
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

		private 

		def create_stack
			template = File.open( rendered_file ).read
			@stack = @cfm.stacks.create( @branch_name, template)
			while @stack.status == "CREATE_IN_PROGRESS"
				msg = "Stack: #{@branch_name} - CREATE_IN_PROGRESS"
				puts msg.yellow
				Rails.logger.info( msg )
				sleep( 5 )
			end
			Rails.logger.info( "Stack State: #{@stack.status}" )
			@stack.events.each do |event|
				msg = "Event: #{event.logical_resource_id} - #{event.resource_status} - #{event.resource_status_resason}"
				Rails.logger.info( msg )
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
