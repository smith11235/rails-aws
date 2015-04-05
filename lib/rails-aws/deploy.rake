namespace :aws do

  namespace :deploy do


    namespace :create do
      desc "Create a new stack for your current repo and branch."
      task prepare: :environment do
        stack_builder = RailsAws::StackBuilder.new

        stack_builder.prepare_new_stack

        system("git status")
        puts "Now execute: $ rake aws:deploy:create:publish".green
      end
    end

    desc "Delete stack and all local resources related to it"
    task delete: :environment do
      stack_builder = RailsAws::StackBuilder.new
      
      cloudformation_file = stack_builder.cloudformation_file
      FileUtils.rm(cloudformation_file) if File.file? cloudformation_file

    end

  end
end
