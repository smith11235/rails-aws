require 'spec_helper'
require 'generator_spec'

describe RailsAws::AwsGenerator do
  let!(:destination_path){ File.expand_path("../../tmp", __FILE__) }
  destination destination_path
  arguments %w(something)

  before(:all) do
    prepare_destination
    run_generator
  end
  
  it "should create a valid config/rails-aws.yml"

  it "should override the config/database.yml file"

  it "should create an aws iam key file" 

  it "should create a deploy key"

  it "should add private files to .gitignore"

end
