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
 
  it "should create an aws iam key file" do
    aws_key_file = "config/aws-keys.yml"
    expect(File.file?(aws_key_file)).to be_true
    aws_key = YAML.load_file aws_key_file
    expect(aws_key.keys.sort).to eq([:access_key_id,:secret_access_key])
  end

  it "should create deploy keys"

  it "should add private files to .gitignore" do
    # %w(config/rails-aws.yml config/rails-aws/ config/aws-keys.yml) 
  end

  it "v2: should update rails projects with a simple config/database.yml"

end
