# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Phase 1
* Key: branch_name
	* create in console.  
	* download 
	* move to ./keys/

* add gem Rake, colorize, rails-aws

* Task: rake create_branch[branch_name]
* Task: rake delete_branch[branch_name]
* Task: rake rebuild_branch[branch_name]

* Security Group: ports: 80/443/22
	* also push server port?

* Tag resources with branch_name

## Phase 2
* EC2: t2.micro
* Elastic IP, on ec2
* key Login

## Phase 2
* snapshot of target database
* create RDBS from snapshot

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