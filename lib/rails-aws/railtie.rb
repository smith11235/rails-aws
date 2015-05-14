module RailsAws
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'rails-aws/tasks.rake' # TODO: remove me

      load 'rails-aws/aws.rake'
    end

    initializer "rails_aws" do
    end

    generators do
      require 'rails-aws/aws_generator'
    end
  end
end
