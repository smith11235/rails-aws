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

      db_type = @config.branch.fetch('database').fetch('db_type')

      if db_type != 'sqlite'
        resources = template.fetch("Resources")
        resources.merge! rds_config
      end

      aws_config_dir = File.dirname(@cloudformation.file) 
      FileUtils.mkdir_p(aws_config_dir) unless File.directory? aws_config_dir
      File.open(@cloudformation.file, 'w') do |f|
        f.puts JSON.pretty_generate(template)
      end
    end

    def delete_stack
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

    def base_config
      load_yml_file(:base_stack_config)
    end

    def load_yml_file(config_file)
      content = File.read File.expand_path("../#{config_file}.yml", __FILE__)
      renderer = ERB.new(content, nil, '%')
      content = renderer.result(binding)
      YAML.load content
    end

    def files_dont_exist_yet
      [@key_pair.key_file, @cloudformation.file].each do |file|
        raise t("stack_builder.errors.file_exists_already", file: file) if File.file? file
      end
    end

    def rds_config
      load_yml_config(:rds_config)
    end
  end
end
