namespace :aws do

  namespace :deploy do

    class CfTemplateBuilder

      def branch
        @branch ||= `git branch | grep \\* | sed 's/^*\\s//'`.rstrip
      end

      def project
        @project ||= `git remote show origin | grep Fetch | sed 's/^.*github.com.//'`.rstrip
      end

      def stack_name
        @stack_name ||= unless @stack_name
                          [project,branch].collect do |name|
                            name.gsub! /\.git$/, ''
                            name.gsub! /(\/|\\)/, '-'
                            name.gsub! /_/, '-'
                            name
                          end.join('-')
                        end
      end
    end

    desc "Create a new stack for your current repo and branch."
    task create: :environment do

      cf_template_builder = CfTemplateBuilder.new
      puts cf_template_builder.stack_name

=begin

      cloudformation_file = "config/rails-aws/#{branch}.json"
    key_pair = RailsAWS::KeyPair.new

    if RailsAWS.db_type != :sqlite
      db_password_file = RailsAWS.dbpassword_file 
      unless File.file? db_password_file
        RailsAWS.set_dbpassword
      else
        puts "Reusing previously created dbpassword: #{db_password_file}".yellow
      end
    end

    cloudformation = RailsAWS::Cloudformation.new

    key_pair.create!
    cloudformation.create!

=end
    end
  end

end
