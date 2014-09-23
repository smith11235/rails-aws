# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Phase 1
* build_env: install aws api/rubygem
* load_env_script
* rails-aws gem

### gem: rails-aws
* thor task, set keys

* Task: rake aws:build_branch[branch_name]
	* branch exists?
	* create key
		* http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/EC2/KeyPair.html
		* save to **./aws-keys/**
* Task: rake aws:delete_branch[branch_name]
	* delete key in cloud and locally
* Task: rake aws:status[branch_name(optional)]
	* show keys
	* show stacks
	* show single stack

### Cloudformation
* templates expected at cloudformation/*.json.erb
	* vars:
		* branch_name
		* deployer

* Security Group: 
	* ports: 80/443/22
* Tag resources with:
	* branch_name
	* deployer (USER)

## Phase 2
* EC2: t2.micro
* also push server port?
* also push redis/resque?
* Elastic IP, on ec2
* key Login

## Phase 3
* snapshot of target database
* create RDBS from snapshot

## Phase 4
* Rails setup

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