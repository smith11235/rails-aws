class BackupTask < Rails::Railtie
	rake_tasks do
  	Dir.glob( File.join(File.dirname(__FILE__),'*.rake') ).each do |rake_file|
			load rake_file
		end
	end
end
