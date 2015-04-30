module RailsAws
  class StackBuilder
    include RailsAws

    def initialize
      @config = RailsAws::Config.new
      @key_pair = RailsAws::KeyPair.new
      @cloudformation = RailsAws::Cloudformation.new
    end

    def publish_new_stack
      raise t("stack_builder.errors.file_missing", file: @cloudformation.file) unless File.file? @cloudformation.file
      raise t("stack_builder.errors.stack_exists_already", stack_name: @cloudformation.stack_name) if @cloudformation.exists?

      raise t("stack_builder.errors.file_exists_already", file: @key_pair.key_file) if File.file? @key_pair.key_file

      raise t("stack_builder.errors.keypair_exists_already", key_name: @key_pair.key_name) if @key_pair.exists?

      @key_pair.create

      @cloudformation.create
    end

    def prepare_new_stack
      files_dont_exist_yet

      template = base_config

      db_type(@config.branch.fetch('database').fetch('db_type'))

      resources = template.fetch("Resources")
      if db_type != 'sqlite'
        db_instance_type(@config.branch.fetch('database').fetch('instance_type'))
        resources.merge!(rds_config) 
      end
      resources.merge!(eb_config)

      print_file(template, @cloudformation.file)
    end

    def print_file(template, output_file)
      aws_config_dir = File.dirname(output_file) 
      FileUtils.mkdir_p(aws_config_dir) unless File.directory? aws_config_dir
      File.open(output_file, 'w') do |f|
        f.puts JSON.pretty_generate(template)
      end
      puts "Generated: #{output_file}"
    end

    def delete_stack
      # DELETE cloudformation
      @cloudformation.delete
      FileUtils.rm(@cloudformation.file) if File.file? @cloudformation.file

      @key_pair.delete
      FileUtils.rm(@key_pair.key_file) if File.file? @key_pair.key_file

    end

    def db_instance_type(type = nil)
      @db_instance_type ||= type
    end

    def db_type(type = nil)
      @db_type ||= type
    end

    def prepare_developer_stack
      @developer_name = @config.developer.fetch('name')

      template = base_config
      resources = template.fetch("Resources")

      db_type(@config.developer.fetch('database').fetch('db_type'))
      if db_type != 'sqlite'
        db_instance_type(@config.developer.fetch('database').fetch('instance_type'))
        resources.merge!(rds_config) 
      end

      resources.merge!(developer_config)

      print_file(template, "config/aws-stacks/developer-#{@developer_name}.json")
    end

    def publish_developer_stack
      @key_pair.create
      @cloudformation.create
    end

    def delete_developer_stack
      # DELETE cloudformation
      @cloudformation.delete
      FileUtils.rm(@cloudformation.file) if File.file? @cloudformation.file

      @key_pair.delete
      FileUtils.rm(@key_pair.key_file) if File.file? @key_pair.key_file
    end

    private

    def stack_name
      @config.current_stack_name
    end

    def load_yml_file(config_file)
      full_file_path = config_file
      ['', 'cloudformation/'].each do |prefix| # TODO: move everything to subfolder
        file_path = File.expand_path(File.join("../#{prefix}", "#{config_file}.yml"), __FILE__)
        full_file_path = file_path if File.file? file_path
      end
      content = File.read full_file_path
      renderer = ERB.new(content, nil, '%')
      content = renderer.result(binding)
      YAML.load content
    end

    def files_dont_exist_yet
      [@key_pair.key_file, @cloudformation.file].each do |file|
        raise t("stack_builder.errors.file_exists_already", file: file) if File.file? file
      end
    end

    def base_config
      load_yml_file(:base_stack)
    end

    def developer_config
      load_yml_file(:developer)
    end

    def eb_config
      load_yml_file(:elastic_beanstalk)
    end

    def rds_config
      load_yml_file(:developer)
    end

    def rds_config
      load_yml_file(:rds)
    end
  end
end
