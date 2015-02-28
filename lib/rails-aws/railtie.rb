module RailsAws
  class Railtie < Rails::Railtie
  	rake_tasks do
			load 'rails-aws/tasks.rake'
  	end

    initializer "rails_aws" do
    end

		generators do
			require 'rails-aws/setup_generator'
		end
  end
end
