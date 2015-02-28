module RailsAws
	class Config

	def initialize
		@config = YAML.load_file( File.join( Rails.root, 'config/rails-aws.yml' ) )
	end

	def default_project_settings
		{
      default: {
        account_id: "180190769793",
        region: "us-east-1",
        ami: "ami-8afb51e2",
        app: {
          instance_type: "t1.micro"
				},
        database: {
          instance_type: "local",
				  db_type: "sqlite"
				}
			}
		}
	end

	def set_project(project_name)
		unless project_names.include? project_name
  		project_names = @config.keys.sort.to_yaml
  		key = "Missing project: %{project_name}, try: %{project_names}"
  		raise t(key, project_name: project_name, project_names: project_names ).red
		end
		@project_name = project_name
	end

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
	end
end
