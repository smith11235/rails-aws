module RailsAws
  class StackBuilder
    include RailsAws

    def initialize
      @config = RailsAws::Config.new
      @key_pair = RailsAws::KeyPair.new
    end

    def cloudformation_file
      "config/aws-stacks/#{@config.current_stack_name}.json"
    end

    def publish_new_stack
      raise t("stack_builder.errors.file_missing", file: cloudformation_file) unless File.file? cloudformation_file
      raise t("stack_builder.errors.file_exists_already", file: @key_pair.key_file) if File.file? @key_pair.key_file

      raise t("stack_builder.errors.keypair_exists_already", key_name: @key_pair.key_name) if @key_pair.exists?

      @key_pair.create
    end

    def prepare_new_stack
      files_dont_exist_yet

      template = base_config

      db_type = @config.branch.fetch('database').fetch('db_type')

      if db_type != 'sqlite'
        resources = template.fetch("Resources")
        resources.merge! rds_config
      end

      aws_config_dir = File.dirname(cloudformation_file) 
      FileUtils.mkdir_p(aws_config_dir) unless File.directory? aws_config_dir
      File.open(cloudformation_file, 'w') do |f|
        f.puts JSON.pretty_generate(template)
      end
    end

    def delete_stack
      # DELETE cloudformation

      FileUtils.rm(cloudformation_file) if File.file? cloudformation_file

      @key_pair.delete
      FileUtils.rm(@key_pair.key_file) if File.file? @key_pair.key_file

    end

    private

    def stack_name
      @config.current_stack_name
    end

    def base_config
      content = File.read File.expand_path("../base_stack_config.yml", __FILE__)

      renderer = ERB.new(content, nil, '%')
      content = renderer.result(binding)

      YAML.load content
    end

    def files_dont_exist_yet
      [@key_pair.key_file, cloudformation_file].each do |file|
        raise t("stack_builder.errors.file_exists_already", file: file) if File.file? file
      end
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
end
