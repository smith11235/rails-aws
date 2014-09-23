namespace :aws do
	task :create_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?
	end
	task :delete_stack, [:branch_name] => :environment do |t,args|
		raise "Missing branch name" if args[:branch_name].nil?
	end
	task :status => :environment do 
		puts "Hello World".green
	end

end
