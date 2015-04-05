namespace :aws do

  namespace :deploy do

    class StackBuilder

      def initialize
        @config = RailsAws::Config.new
      end

      def prepare_new_stack
        files_dont_exist_yet

        template = base_config

        db_type = @config.branch.fetch('database').fetch('db_type')
        if db_type != 'sqlite'
          raise "Add rds_config, set type and instance_type"
        end

        aws_config_dir = File.dirname(cloudformation_file) 
        FileUtils.mkdir_p(aws_config_dir) unless File.directory? aws_config_dir
        File.open(cloudformation_file, 'w') do |f|
          f.puts JSON.pretty_generate(template)
        end
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

      def rds_config
        {
          "RDS" => {
            "Type" => "AWS=>=>RDS=>=>DBInstance",
            "Properties" =>
            {
              "AllocatedStorage" => "50",
              "AllowMajorVersionUpgrade" => true,
              "AutoMinorVersionUpgrade" => true,
              "BackupRetentionPeriod" => "2",
              "DBInstanceClass" => @config.branch.fetch('database').fetch('instance_type'),
              "VPCSecurityGroups"=> [ {"Ref"=> "SecurityGroup"} ],
              "Engine" => @config.branch.fetch('database').fetch('db_type'),
              "DBName" => "railsapp", 
              "MasterUsername" => "railsapp",
              "MasterUserPassword" => "5aed99058d873716ebec7111b2e679dc",
              "MultiAZ" => false,
              "PubliclyAccessible" => false,
              "DBSubnetGroupName"=> { "Ref"=> "RDSSubnet" },
              "Tags" => [ {"Key"=> "Name", "Value"=> stack_name } ]
            }
          },
          "RDSSubnet"=> {
            "Type" => "AWS=>=>RDS=>=>DBSubnetGroup",
            "Properties" => {
              "DBSubnetGroupDescription" => stack_name,
              "SubnetIds" => [ {"Ref"=> "subnet" }, { "Ref"=> "subnet2" } ],
              "Tags" => [ {"Key"=> "Name", "Value"=> stack_name } ]
            }
          }
        }
      end
    end

    namespace :create do
      desc "Create a new stack for your current repo and branch."
      task prepare: :environment do

        stack_builder = StackBuilder.new

        stack_builder.prepare_new_stack

        system("git status")
        puts "Now execute: $ rake aws:deploy:create:publish".green
      end
    end

  end
end
