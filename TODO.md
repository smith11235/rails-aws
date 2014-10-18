# Development Plan

* complex release task 
* thin/rackup setup/startup, single host
* domain update delay elimination with eip-association
* vpc
* shared db
* thin/rackup separate server: bigger domain_instance

## Phase: Domain Update Delay

* domain setup should include:
	* eip
		* http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip.html
	* eipassociation for ec2 of domain_branch
		* http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-eip-association.html
		* this should change instead of domain record
			* RailsAWS.instance_id
				* load stack definition, 
				* if doesnt exist, no association should be created
					* just domain and ip
				* update/exists
					* add eip association
					* with ec2 instance id from stack api
	* set no public ip for ec2 server

```
	def eip_name
		branch_name + "eip"
	end

  def eip_association_name
    branch_name + "eipas"
  end

  "<%= eip_name %>" : {
     "Type" : "AWS::EC2::EIP",
     "Properties" : {
     }
  },
  "<%= eip_association_name %>" : {
     "Type": "AWS::EC2::EIPAssociation",
     "Properties": {
        "EIP": { "Ref": "<%= eip_name %>" },
        "InstanceId": { "Ref": "<%= RailsAWS.instance_id %>" },
     }
  }
```

## Phase: Easier release workflow

* r aws:release[version,rds_id=nil] RAILS_ENV=production
	* version =~ /^\d+\.\d+\.\d+$/
	* system "git checkout master"
	* system "git pull origin master"
	* master-version = `cat VERSION`.chomp
	* branch = "rails-aws-release-#{version}"
  * system "git checkout -b $branch"
	* system "echo '#{version}' > VERSION"
	* system "git add VERSION"
	* system "git commit -am 'updating version to $version'"
	* system "git push origin $branch"
	* if rds_id.nil? 
    * check if an existing production db exists and snapshot it
		* unless its set to 'new-db'
	* if rds_id.db.exists? rds_create_snapshot[rds_id]
	* elif rds_id.snapshot.exists? rds_set_snapshot[rds_id]
	* else clear snapshot file
  * stack_create[branch]
  * cap_deploy[branch]
	* system "git add ."
	* system "git commit -am 'updating stack-info'"
	* system "git push origin $branch"
* if you are replacing your production stack:
	* r aws:domain_update[branch=nil] # to publish your production release
		* if branch is a new branch:
			* sed -i 's/domain_branch.*$/domain_branch: $branch/' config/rails-aws.yml
			* confirm it exists and responds
			* update

## Push server on web server
* push_server: local 
	* really good example: 
		* http://stackoverflow.com/questions/13030149/how-to-deploy-ruby-rack-app-with-nginx
	* rails-aws.yml setting
		* push_server: local
	* ```Thread.new { system("rackup private_pub.ru -s thin -E production") }``` in initializer
	* security group port:
		* 9292
	* edit config/private_pub.yml
		* production + dev should match
		* server should be localhost 
	* add port to nginx config

		```
      upstream rack_upstream {
        server 127.0.0.1:9292;
      }
      
      server {
        listen       80;
        server_name  domain.tld;
        charset UTF-8;
      
        location /faye {
     
          proxy_pass http://rack_upstream;
          proxy_redirect     off;
          proxy_set_header   Host             $host;
          proxy_set_header   X-Real-IP        $remote_addr;
          proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        }
      
      }
		```

* second server:
	* https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#_tutorial_example_writing_and_deploying_a_hello_world_rack_application
	* or merge .ru files and use "HOST_TYPE=[rails|push]"
		* make config.ru managed

* nginx/passenger rackup
	* tutorial: https://gist.github.com/twetzel/3157812
	* example: https://gist.github.com/meskyanichi/986075
		* add push_secret
* partyshuffle:  
	* push_server
	* private_pub.ru # rename it config.ru? in another install location???
		* or just on secondary server?

## Phase: Database Replacement
* single sourcing your release branches on a static rds instance
* 0 downtime deployment
* requires vpc (to not have a publically accessible database)

## VPC: Minimal Downtime
* if we have vpc
* if we update it with a new substack
* corun two stacks internally
* domain points to gateway
* gateway points to determined current production host
* repointed when ready
* db hosts are easily reused or rebuilt


## Phase: Setup Generator Update

* for rails-aws.yml, aws-keys.yml, db-type
	* load existing values, <enter> uses default
* ask for domain and domain_branch

## Phase: Additional AWS Resources
* EC2:
	* push
  	* private-pub
  * resque: 
  	* resque-worker
  	* redis

## Phase: dbpassword_file in gitignore
* add to generator
* temporarily its behind ssh access and security group

## Phase: Update Stack
- task: 
	- cap_generate_secret: if file doesnt exist
	- cap_start_rails_server: touch tmp/restart.txt
## Phase
- rake aws:check_setup (rails-aws.yml)
  - and clean up documentation


## Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

## Phase: SSL

* setup ssl requirements
* nginx config

```
  server {       
    listen         80;
    server_name 54.165.219.61;       
    rewrite        ^ https://$server_name$request_uri? permanent;
  }
```

* enforce_https|ssl
	* config/environments/production.rb: has directive
	* or add to application controller

## Phase
- make a security check on startup?
	- for rake, generator, rails, capistrano


## TTL lifetime

To save money, on startup.
Process to delete in background



## Phase: VPC 

# Application Setup (Not as recommended)

The directory name for the clone is based on a **1 rails-aws <=> 1 application to deploy** relationship.

Later this will be 1 to many for easy cloud management from your local machine or rails-aws.com.

```
  # where [your-app-name] is your repohost.com/username/your-app-name
  # example
  ~/ $ git clone git@github.com:smith11235/rails-aws.git rails-aws-[your-app-name]
```

Build the rvm/ruby environment.  May require sudo for needed ruby libraries.

```
  sh build_ruby_env.sh
  source load_ruby_env.sh
```

## Config Values For Login

File: **/etc/ssh/sshd_config**

```       
  PermitRootLogin no      
  UsePAM no      
  RSAAuthentication yes # default      
  PubkeyAuthentication yes       # default
  ChallengeResponseAuthentication no  # default
  PasswordAuthentication no  # default
``` 
