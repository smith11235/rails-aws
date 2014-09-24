module RailsAWS
	class Cloudformation

		def initialize( branch_name )
			@branch_name = branch_name

			@cfm = RailsAWS::CFMClient.get

			@template_file = File.expand_path( "../stack.json.erb", __FILE__ )

			@output_dir = File.join( Rails.root, 'cloudformation' )
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
		end

		def create!
			if exists?
				msg = "Cloudformation stack exists: #{@branch_name}".red
				Rails.logger.fatal msg
				raise msg
			end

			render_erb

		end

		private 

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
