module RailsAws

  class Cloudformation
    include RailsAws

    def initialize
      @config = RailsAws::Config.new
      @cfm = RailsAws.cfm_client
    end
    
    def deploy_timestamp
      @deploy_timestamp ||= DateTime.now.strftime('%Y-%m-%d-%H-%M')
    end

    def s3_key
     "#{stack_name}/#{deploy_timestamp}.zip"
    end

    def file
      "config/aws-stacks/#{@config.current_stack_name}.json"
    end

    def stack_name
      @config.current_stack_name
    end

    def exists?
      @cfm.stacks[stack_name].exists?
    end

    def current_stack
      @cfm.stacks[stack_name]
    end

    def create
      upload_app_bundle

      @stack = @cfm.stacks.create(stack_name, template)

      track_stack( "CREATE_IN_PROGRESS", "CREATE_COMPLETE" )
    end

    def delete
      return unless exists?
      logger t("cloudformation.delete.initial", stack_name: stack_name, status: current_stack.status)
      current_stack.delete
      sleep(2)

      while current_stack.exists? && current_stack.status == "DELETE_IN_PROGRESS"
        logger "- #{stack_name}: #{current_stack.status}"
        sleep(10)
      end

      if current_stack.exists?
        msg = t("cloudformation.delete.failed", stack_name: stack_name, status: current_stack.status)

        logger msg 
        raise msg
      end

      logger t("cloudformation.delete.complete", stack_name: stack_name)
    end

    private

    def upload_app_bundle
      deploy_file = "#{deploy_timestamp}.zip"
      raise "Unable to zip app: #{deploy_file}" unless system("zip -r --exclude=*.rvm* #{deploy_file} .")
      raise "Missing zip: #{deploy_file}" unless File.file? deploy_file
      s3_bucket = "railsaws"
      s3 = AWS::S3.new
      s3.buckets[s3_bucket].objects[s3_key].write(:file => deploy_file)
    end

    def show_stack_events
      current_stack.events.each_with_index do |event|
        logger "  - Event: #{event.logical_resource_id} - #{event.resource_status} - #{event.resource_status_reason}"
      end
    end

    def show_stack_status
      logger "- #{stack_name} - #{current_stack.status}"

=begin
      current_stack.resources.each do |resource|
        logger "  - Resource: #{resource.resource_type}: #{resource.resource_status} # #{resource.resource_status_reason}"
      end
=end
    end

    def track_stack( starting_status, ending_status )
      sleep(2)
      logger t("cloudformation.track_stack.initial", stack_name: stack_name, initial: starting_status, expecting: ending_status)

      while current_stack.status == starting_status
        show_stack_status
        puts "#{l(DateTime.now)} - #{t("cloudformation.sleeping")}"
        sleep(30)
      end

      show_stack_status
      show_stack_events

      unless received_status = current_stack.status == ending_status
        msg = t("cloudformation.track_stack.failed", stack_name: stack_name, expected: ending_status, received: received_status)
        logger msg
        raise msg
      end
    end

    def template
      File.read self.file
    end
  end
end
