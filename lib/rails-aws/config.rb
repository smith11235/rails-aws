module RailsAws

	class Config
		include RailsAws
		attr_reader :project
		attr_reader :branch

		def initialize(config_text=nil)
			config_file = File.join(Rails.root, 'config/rails-aws.yml')
			@config = if File.file?(config_file) && !config_text
									RailsAws.logger(t("config.loading_config_file", config_file: config_file))
									YAML.load_file(config_file)
								else
									if !config_text
										false
									else
									  RailsAws.logger(t("config.loading_config_text", config_file: config_file, passed_text: config_text))
									  YAML.load config_text
									end
								end
		end

		def valid?
			!(@config.nil? || @config == false)
		end
		def projects
			@config.keys.sort
		end

		def set_branch(branch_name)
			@branch_name = branch_name
			RailsAws.logger @config.to_yaml
			@branch = if @project.has_key? @branch_name
									@project.fetch @branch_name
								else
									Hash.new
								end
			if @project.has_key? 'default'
				@project['default'].each do |key,value|
					@branch[key] ||= value
					if value.is_a? Hash
						@branch[key].reverse_merge value
					end
				end
			end
			default_branch_settings.each do |key,value|
				@branch[key] ||= value
				if value.is_a? Hash
					@branch[key].reverse_merge value
				end
			end
		end

		def default_branch_settings
			{
				'region' => "us-east-1",
				'ami' => "ami-8afb51e2",
				'app' => {
					'instance_type' => "t1.micro"
				},
				'database' => {
					'instance_type' => "local",
					'db_type' => "sqlite"
				}
			}
			
		end

		def set_project(project_name)
			project_names = @config.keys.sort.to_yaml
			unless project_names.include? project_name
				key = "config.missing_project_error"
				raise t(key, project_name: project_name, project_names: project_names ).red
			end
			@project_name = project_name
			@project = @config.fetch @project_name
		end


=begin
		def branch
			@branch ||= `git status`[/On\sbranch\s.+$/].split(' ').last
		end

		def environment
			env = Rails.env
			raise "Support production/development only" unless %w(production development).include? env
			env
		end

		def branch_dir
			branch_dir = File.join( Rails.root, 'config/branch', RailsAWS.branch )
			FileUtils.mkdir_p branch_dir unless File.directory?( branch_dir )
			branch_dir
		end

		def self.stack_definition
			config_has = RailsAWS.config_hash
			stack_file = config_hash[ 'stack_definition' ] || 'lib/rails-aws/stack.json.erb'
			stack_file = File.expand_path stack_file 
			raise "Missing stack_definition: #{stack_file}".red unless File.file? stack_file
			stack_file
		end

		# in rails-aws.rb
		def self.db_type
			# db_type = ActiveRecord::Base.connection.adapter_name.downcase
			config_key = "db_type_#{RailsAWS.environment}".to_sym
			db_type = RailsAWS.config( config_key )

			db_type = case db_type
								when /^mysql/
									:mysql
								when /^sqlite/
									:sqlite
								else
									raise "Unsupported db type: #{db_type}"
								end
			db_type
		end

		def self.ami_id
			# from: http://cloud-images.ubuntu.com/locator/ec2/
			RailsAWS.config( :ami_id )
		end
=end
	end
end
