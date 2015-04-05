# Rails Aws

Manage all your projects.
Manage each branch of your project.
Manage them locally for easy key management.
Integrate with Lastpass and 1Password.
Versioned, revision controlled hardware and software.
Local server provides dashboard for management.
Use easy pro stacks for the best modern website possible.
All based on AWS for easy infinite expansion.
Run a development server.
This app is what runs on port 80.

## Priorities

#### V1

#### v2: aws:deploy:create:publish

* aws:deploy:delete
  * [ ] delete cloudformation stack
  * [ ] delete cloudformation file
  * [ ] delete keypair
  * [ ] delete keypair file

* aws:deploy:create:publish
  * [ ] expect files
  * [ ] expect no stack
  * [ ] create keypair
  * [ ] create stack

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
#### V*
* domain name setup
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
