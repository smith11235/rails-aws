# Provisioning

For all of these:

```
  export branch=my_branch
	export RAILS_ENV=production
	alias r="bundle exec rake"
```

## New Project Or Clean Slate Install

```
  r aws:stack_create[$branch] aws:cap_deploy[$branch] aws:domain_create[$branch]
  # login to website
```

## New Build From Existing AWS Database

```
  r aws:rds_info
  > select a database_id to snapshot
	r aws:rds_create_snapshot[$branch,database_id]
  r aws:stack_create[$branch] aws:cap_deploy[$branch] aws:domain_create[$branch]
  # login to website
```

## Rebuilding Client Facing Production

```
  git checkout master
	export prior_branch=release-1.0.0
	export branch=release-1.0.1
  git checkout -b $branch 
	git push origin $branch

  r aws:rds_info
  > select the database_id for database '[application]-release-A.B.C' (current production)

	r aws:rds_create_snapshot[$branch,database_id]
  # from this point on until you have published you will be losing data written to the db
  # for a small case this could be 10 minutes. Future improvements are being made
  # set maintenance banners on your website to notify clients or prevent writes to your database.

	r aws:create_stack[$branch] aws:cap_deploy[$branch] 
	> test site: wget IPADDRESS
	sed -i "s/^domain_branch:.*\$/domain_branch: $branch/" config/rails-aws.yml
	r aws:domain_update
	wget domain.com
	r aws:delete_stack[$prior_branch]
	git add .
	git commit 
	git push origin $release
```

## Dev Builds

```
  git checkout master
	export branch=my_branch
	git checkout -b $branch

  # repeat below as needed:

  > edit stuff
	git add .
	git commit  
	git push origin $branch

  # initial build or for clean rebuilds 
	r aws:stack_delete[$branch,no_error] aws:stack_create[$branch] aws:cap_deploy[$branch] 

  # for quicker rails code testing updates after initial build
	r aws:cap_deploy[$branch]
```
