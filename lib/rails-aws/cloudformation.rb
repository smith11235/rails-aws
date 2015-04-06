module RailsAws

  class Cloudformation
    include RailsAws

    def initialize
      @config = RailsAws::Config.new
      @cfm = RailsAws.cfm_client
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
  end
end
