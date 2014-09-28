# Git Deploy Keys

**Note** If you are running the rails server you can view this at http://localhost/git_deploy_keys.md

**rails-aws** works by using ssh-keys on the amazon ec2 instances for fetching the code base.

As such these keys will be generated and stored in the location you run this from.

This can be overriden with manual edits to **config/rails-aws.yml**

## Setting Up Github

Take the contents that are printed to screen after you read this.

Go to your repository and add a deployment key.

For the rails-aws project that would be: https://github.com/smith11235/rails-aws/settings/keys

Suggested key naming is **rails-aws** since you will need one per repo.
