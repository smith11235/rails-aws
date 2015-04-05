namespace :aws do

  namespace :deploy do

    class StackBuilder

      def initialize
        @config = RailsAws::Config.new
      end

      def prepare_new_stack
        files_dont_exist_yet

        puts base_config.to_yaml
      end

      private

      def stack_name
        @config.current_stack_name
      end

      def base_config
        YAML.load_file "lib/rails-aws/base_stack_config.yml"
      end

      def files_dont_exist_yet
        [key_file, cloudformation_file].each do |file|
          raise t("deploy.errors.file_exists_already", file: file) if File.file? file
        end
      end

      def cloudformation_file
        "config/aws-stacks/#{@config.current_stack_name}.json"
      end

      def key_file
        "config/aws-stacks/#{@config.current_stack_name}.key"
      end

    end

    namespace :create do
      desc "Create a new stack for your current repo and branch."
      task prepare: :environment do

        stack_builder = StackBuilder.new

        stack_builder.prepare_new_stack


=begin

      cloudformation_file = "config/rails-aws/#{branch}.json"
    key_pair = RailsAWS::KeyPair.new

    if RailsAWS.db_type != :sqlite
      db_password_file = RailsAWS.dbpassword_file 
      unless File.file? db_password_file
        RailsAWS.set_dbpassword
      else
        puts "Reusing previously created dbpassword: #{db_password_file}".yellow
      end
    end

    cloudformation = RailsAWS::Cloudformation.new

    key_pair.create!
    cloudformation.create!

=end
      end
    end

  end
end
