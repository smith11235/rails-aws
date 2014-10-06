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
  git checkout -b release-X.Y.Z
	git push origin release-X.Y.Z

  r aws:rds_info
  > select the database_id for database '[application]-release-A.B.C' (current production)

	r aws:rds_create_snapshot[$branch,database_id]
  # from this point on until you have published you will be losing data written to the db
  # for a small case this could be 10 minutes. Future improvements are being made
  # set maintenance banners on your website to notify clients or prevent writes to your database.

  r aws:stack_create[$branch] aws:cap_deploy[$branch] aws:domain_create[$branch]
```
