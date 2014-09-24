# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Usage

### Project Setup
* clone repo
* sh build_ruby_env.sh
* cd RailsAws
* bundle install --deployment
* rails g rails_a_w_s:setup

### Stack Management
* rake aws:[create|delete]_stack[branch_name]
* rake aws:status
* tail log/development.log

## Phase 1.1
* add zues, save time
* add pry, save time

## Phase 2
* rails install on ec2
```
  "yum -y install gcc-c++ make","\n",
  "yum -y install mysql-devel sqlite-devel","\n",
  "yum -y install ruby-rdoc rubygems ruby-mysql ruby-devel","\n",
  "gem install --no-ri --no-rdoc rails","\n",
  "gem install --no-ri --no-rdoc mysql","\n",
  "gem install --no-ri --no-rdoc sqlite3","\n",
  "rails new myapp","\n",
  "cd myapp","\n",
  "rails server -d","\n",
```
* Login
* website access
* Elastic IP? or route53?

## Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

## Phase 3
* snapshot of target database
* create RDBS from snapshot

## Phase 4
* Rails setup

## Phase
* also push server port?
* also push redis/resque?

## Shutdown/startup
* ttl/cost savings

## Phase 3
* cloud-init:
	* rails install
	* git branch
	* Gemfile

## Phase 4
* external access at http://[IP] 

## Phase 5
* domain name to ip in route 53

## Phase 6
* subnets
* vpc

## Phase 7
* ssl support

## Phase 6
* app server
	* redis
	* resque?
	* push server

## AWS Resources
* Key
* VPC
* subnet:
	* allow 22 on all hosts
	* key auth only
	* port 80/443 on web
	* internal networking open

* RDS: 
	* mysql as per current
	* db from a snapshot: parameter

* EC2:
	* service: 
		* resque-worker
		* private-pub
	* web: 
		* rails server through passenger 

## Deployment Process
* generate a [Key Pair](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-keypair.html)
* take snapshot of current rds
* run template with correct param values
* test
* migrate route 53

## AWS Example

[example](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-waitcondition-article.html)