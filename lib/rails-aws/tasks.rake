namespace :aws do

	desc "Create a new stack from [branch_name]"
	task :create_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?
	end

	desc "Delete a stack from [branch_name]"
	task :delete_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?
	end

	desc "Show status for all stacks"
	task :status => :environment do 
		puts "Hello World".green
	end

end
