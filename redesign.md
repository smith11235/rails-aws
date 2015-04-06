# Rails Aws

Publish your 'production' branch and any development branch you want tested like production.

Revision controlled, pull requestable, hardware and software.

All based on AWS with extensible json deployment configuration.

## Workflow

* deploy production setups
  * for any branch you need
    * commands operate on your current repo and branch
  * private VPC
  * standalone DB
  * Rails on Elastic Beanstalk
  * Safe, instant publishing and rollback of application versions.

#### Deploying a test build or production

```
  git checkout master # pretend master is your production build
  rake aws:deploy:create:prepare
  rake aws:deploy:create:publish

  rake aws:deploy:delete
```

#### Deploying an Update

```
  git checkout master
  rake aws:deploy:update:prepare
  # Pull Request and review the platform change
  rake aws:deploy:update:build_shadow_stack
  # test your shadow stack at shadow.[yourdomain].com
  rake aws:deploy:update:publish_shadow_stack

  # if something breaks in production, immediately revert it
  rake aws:deploy:update:revert_publish

  # when you are happy with your release
  rake aws:deploy:update:delete_previous_version
```

## Priorities

#### v3

* EB Application
  * http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-beanstalk.html
* EB Application Version
  * http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-beanstalk-version.html
  * how to create a source bundle?
* EB Config
  * http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-beanstalk-configurationtemplate.html
* Environment
  * http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-beanstalk-environment.html

#### create railsaws s3 bucket

#### Update commands

#### V* Outputs

* eb: Fn::GetAtt, ebenvironment, EndpointURL
  * awseb-myst-myen-132MQC4KRLAMD-1371280482.us-east-1.elb.amazonaws.com
* add them to an outputs: key in the config files

#### v?
* add single or multi tenant development environment
  * to master environment
    * single tenant: dev.[domain.com]
    * multi tenant: [user].dev.[domain.com] 

#### V*
* domain name setup

#### Review Generator
* and iam gitignore, keyfile

#### v4 
* better options, env config, etc
* options, scaling, monitoring
  * http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options.html

* prepare_update[master]
  * new app version
  * new eb environment

* publish_update[master]
  * cname swap

* https://github.com/smith11235/rails-aws/milestones/V1%20-%20Remake%20-%20Production%20Quality

### EC2 server

      "devec2" : {
        "Type" : "AWS::EC2::Instance",
        "DependsOn" : [ "attachgateway" ],
        "Properties" : {
          "KeyName" : "bw-dev-smith",
          "InstanceType": "t2.micro",
          "SubnetId" : { "Ref": "subnet" },
          "SecurityGroupIds" : [ {"Ref": "SecurityGroup" } ],
          "ImageId" : "ami-9a562df2",
          "UserData" : {
            "Fn::Base64" : {
              "Fn::Join" : ["",[
                "#!/bin/bash -v\n"
                ]]
            }
          },
          "Tags": [ { "Key": "Name", "Value": "smith-dev" } ]
        }
      },
      "dnsname": {
        "Type": "AWS::Route53::RecordSetGroup",
        "Properties": {
          "HostedZoneName": "rails-aws.com.",
          "Comment": "Subdomain record for ec2 server access",
          "RecordSets": [
          {
            "Name": "dev.rails-aws.com.",
            "Type": "CNAME",
            "TTL": "60",
            "ResourceRecords": [
            { "Fn::GetAtt" : [ "devec2", "PublicDnsName" ] } 
            ]
          },
          {
            "Name": "test.rails-aws.com.",
            "Type": "CNAME",
            "TTL": "60",
            "ResourceRecords": [
            { "Fn::GetAtt" : [ "devec2", "PublicDnsName" ] } 
            ]
          },
          {
            "Name": "mail.rails-aws.com.",
            "Type": "CNAME",
            "TTL": "60",
            "ResourceRecords": [
            { "Fn::GetAtt" : [ "devec2", "PublicDnsName" ] } 
            ]
          }
          ]
        }
      },

### EIP/vs CNAME swap

      "ec2eip": {
        "Type" : "AWS::EC2::EIP",
        "Properties" : {
          "Domain" : "vpc" 
        }
      },
      "ec2eipassoc" : {
        "Type" : "AWS::EC2::EIPAssociation",
        "Properties" : {
          "AllocationId" : { "Fn::GetAtt" : [ "ec2eip", "AllocationId" ]},
          "InstanceId" : { "Ref" : "devec2" }
        }
      },

### V2

* rails-aws UI can be used locally (rails server -p 3000)
  * no user accounts or shared hosted instances

### V3

* with user accounts and real security
* a hosted and shared instance could be made
* allowing a team to share simple control
  
## Config File

```
  ---
  default: # full service micro instance
   app:            t1.micro
   database:       local
   sidekiq_redis:  local
   faye:           local

  for-fun-project:
    git-repo: https://github.com/wicked/wicked.git
    development: 
     &default
    production: 
     &default

  my-cool-project:
    git-repo: https://github.com/cool/cool.git

    # micro environments, super cheap
    development: 
     &default
    test:
     &default
  
    demo:            # shared server for secondary services
     app:            m3.small
     database:       t2.medium
     sidekiq_redis:  shared::t2.medium
     faye:           shared::t2.medium
  
    production:      # all dedicated hardware
     instance:       c3.medium
     database:       m3.medium
     sidekiq_redis:  m3.small
     faye:           m3.small
```

## Define your own stack

At any layer of the config set cloudformation_template to another file path.

## Target Initial Stacks

* Rails + RDS
  * + sidekiq, redis, faye.

* Nodejs/Ghost-blog

## Models

* deployment
  * app
  * branch 
  * last_template

## View
* new stack
* current stacks
* create stack
  * real time communication
