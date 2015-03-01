require 'rails-aws'

module RailsAws

  class AwsGenerator < Rails::Generators::Base
    include RailsAws

    source_root File.expand_path("../", __FILE__)

    def rails_aws_settings
      file = destination(File.join("config","rails-aws.yml"))
      return unless modify? file, :confirm => true, :suggested => t("generator.rails_aws.suggested").yellow

      config = Hash.new
      config.merge! YAML.load_file file if File.file? file

      while yes?(t("generator.rails_aws.add_project")) do
        project_name = query(t("generator.rails_aws.project_name"))
        if config.has_key? project_name
          puts t("generator.rails_aws.project_exists_already")
          next
        end
        values = Hash.new
        values[ 'repo_url' ] = query(t("generator.rails_aws.repo_url"), values['repo_url'])
        values[ 'default' ] = Hash.new
        values[ 'default' ][ 'account_id' ] = query(t("generator.rails_aws.account_id"), values['default']['account_id'])
        puts t("generator.rails_aws.settings_note")
        config[ project_name ] = values
        break if Rails.env == "test"
      end

      create_file file do
        config.to_yaml
      end
    end

    def aws_keys_config_file
      file = destination("config/aws-keys.yml")
      if modify? file, :suggested => t('generator.aws_keys.suggested')
        keys = [:access_key_id, :secret_access_key]
        current_values = current_file_values(file)

        values = Hash.new
        values.merge! current_values if current_values

        keys.each do |key|
          values[key] = query(key,values[key])
        end

        create_file file do
          values.to_yaml
        end
      end
    end

    def deploy_keys
      create_keys = yes?(t("generator.deploy_keys.create"))
      return unless create_keys

      config = RailsAws::Config.new
      unless config.valid?
        puts t('generator.deploy_keys.config_error')
        return
      end
      config.projects.each do |project|
        next unless yes?("- " + t("generator.deploy_keys.for_project", project: project))
        key_file = destination(File.join('config', 'rails-aws', project, 'deploy_id_rsa'))
        if modify? key_file, :suggested => t("generator.deploy_keys.suggested")
          deploy_dir = File.dirname key_file
          FileUtils.mkdir deploy_dir unless File.directory? deploy_dir
          system( "ssh-keygen -t rsa -f #{key_file}" )
          puts t("generator.deploy_keys.add_to_repository", key_file: key_file).green
        end
      end
    end

    private

    def query(key,current_value=nil)
      value = test_value || ask(t('generator.ask', default_value: current_value, prompt: key)) 
      value = current_value if value.blank?
      value
    end

    def current_file_values(yaml_file)
      return nil unless File.file? yaml_file
      YAML.load_file yaml_file
    end

    def test_value
      Rails.env == "test" ? "TESTINGvalue" : nil
    end

    def yes?(question)
      return true if Rails.env == "test"
      ask(question + "(y)").downcase == 'y'
    end

    def modify?(file, opts = {})
      opts = opts.reverse_merge( :confirm => false, :suggested => nil  )
      exists_already = File.file?(file)
      answer = if exists_already
                 puts
                 puts t("generator.modify.file", file: file)
                 puts t("generator.modify.suggestion",suggested: opts[:suggested]) if opts[:suggested]
                 yes?(t("generator.modify.check"))
               else
                 true
               end
      answer = if exists_already && answer && opts[:confirm]
                 yes?(t("generator.modify.confirm"))
               else
                 answer
               end
      answer
    end

    def destination(target_file)
      final_path = if Rails.env == "test"
                     File.join('tmp', target_file)
                   else
                     target_file
                   end
      FileUtils.mkdir_p File.dirname(final_path)
      final_path
    end

  end

end
