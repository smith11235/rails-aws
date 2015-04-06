namespace :aws do
  namespace :deploy do
    namespace :create do

      desc "Prepare a new stack for review"
      task prepare: :environment do
        stack_builder = RailsAws::StackBuilder.new

        stack_builder.prepare_new_stack

        system("git status")
        puts "Now execute: $ rake aws:deploy:create:publish".green
      end

      desc "Deploy a new stack"
      task publish: :environment do
        stack_builder = RailsAws::StackBuilder.new
        stack_builder.publish_new_stack
      end

    end

    desc "Delete stack and all local resources related to it"
    task delete: :environment do
      stack_builder = RailsAws::StackBuilder.new
      stack_builder.delete_stack
    end

  end
end
