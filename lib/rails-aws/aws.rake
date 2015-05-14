namespace :aws do
  namespace :developer do
    desc "Prepare a new developer environment"
    task prepare: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.prepare_developer_stack
    end

    desc "Publish a new developer environment"
    task publish: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.publish_developer_stack
    end

    desc "Delete a new developer environment"
    task delete: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.delete_developer_stack
    end
  end

  namespace :stack do # unique to repo + branch

    desc "Prepare a new stack for review"
    task prepare: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.prepare_new_stack
    end

    desc "Deploy a new stack"
    task publish: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.publish_new_stack
    end

    desc "Delete stack and all local resources related to it"
    task delete: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.delete_stack
    end

  end
end
