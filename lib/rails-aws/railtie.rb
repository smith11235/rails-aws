module RailsAWS
  class Railtie < Rails::Railtie
  	rake_tasks do
			load 'rails-aws/tasks.rake'
  	end
  end
end
