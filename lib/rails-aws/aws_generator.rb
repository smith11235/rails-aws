require 'rails-aws'

module RailsAws

  class AwsGenerator < Rails::Generators::Base
    include RailsAws
    
    source_root File.expand_path("../", __FILE__)

    def aws_keys_config_file
      file = "config/aws-keys.yml"
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

    private

    def query(key,current_value)
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

    def modify?(file, opts = {})
      opts = opts.reverse_merge( :confirm => false, :suggested => nil  )
      exists_already = File.file?(file)
      answer = if exists_already
                 puts
                 puts "---".green
                 puts "File: #{file}"
                 puts "Suggested: #{opts[:suggested]}" if opts[:suggested]
                 ask("Do you wish to modify (y)".yellow)  == 'y'
               else
                 true
               end
      answer = if exists_already && answer && opts[:confirm]
                 ask( "Are you sure you wish to modify (Y)".red ) == 'Y'
               else
                 answer
               end
      return answer
    end
  end
end
