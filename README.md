# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Phase 1
* Key: development
* Security Group: ports: 80/443/22
* EC2: t2.micro
* Elastic IP, on ec2
* Login: chec lockin

## Phase 
* cloud-init:
  * Rails install (development,sqlite) project running
* external access at http://[IP] 

## Phase
ip for route 53

## Phase 2
* rds
* or:
	* ec2:
		* ami
		* postgres
		* redis

## Phase 3
* services host
	* resque worker
	* push server
		* or should this be on the web server

## Phase 4
* subnets
* vpc

## Phase 
* ssl support

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