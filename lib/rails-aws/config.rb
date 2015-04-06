module RailsAws

  class Config
    include RailsAws
    attr_reader :branch, :current_branch_name, :current_project_name, :current_stack_name

    def self.current_branch_name
      `git branch | grep \\* | sed 's/^*\\s//'`.rstrip
    end

    def self.current_project_name
      `git remote show origin | grep Fetch | sed 's/^.*github.com.//'`.rstrip
    end

    def self.current_stack_name
      [Config.current_project_name,Config.current_branch_name].collect do |name|
        name.gsub! /\.git$/, ''
        name.gsub! /(\/|\\)/, '-'
        name.gsub! /_/, '-'
        name
      end.join('-')
    end

    def initialize(config_text=nil)
      @config = if config_text # For testing
                  RailsAws.logger(t("config.loading_config_text", config_file: config_file, passed_text: config_text))
                  YAML.load config_text
                else
                  config_file = File.join(Rails.root, 'config/rails-aws.yml')
                  raise t("config.missing_config_file", config_file: config_file) unless File.file?(config_file)
                  RailsAws.logger(t("config.loading_config_file", config_file: config_file))
                  YAML.load_file(config_file)
                end

      @current_branch_name = Config.current_branch_name
      @current_project_name = Config.current_project_name
      @current_stack_name = Config.current_stack_name

      set_branch_config
    end

    def valid?
      !(@config.nil? || @config == false)
    end

    def set_branch_config
      # Use branch specific values if available
      @branch = @config[@current_branch_name] || Hash.new

      # Then use default values if available
      if @config.has_key? 'default'
        @config['default'].each do |key,value|
          @branch[key] ||= value
          if value.is_a? Hash
            @branch[key].reverse_merge value
          end
        end
      end

      # Then gem defaults 
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
