module RailsAWS
  class Railtie < Rails::Railtie
  	rake_tasks do
			load 'rails-aws/tasks.rake'
  	end

		generators do
			require 'rails-aws/setup_generator'
		end
  end
end
