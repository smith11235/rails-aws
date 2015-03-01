require 'spec_helper'
require 'generator_spec'

describe 'RailsAws::AwsGenerator' do
  before(:all) do
    raise "Unable to execute generator successfully" unless system "rails g rails_aws:aws"
  end

  it "should create a valid config/rails-aws.yml" 
 
  it "should create an aws iam key file" do
    aws_key_file = "config/aws-keys.yml"
    expect(File.file?(aws_key_file)).to eq(true)
    aws_key = YAML.load_file aws_key_file
    expect(aws_key.keys.sort).to eq([:access_key_id,:secret_access_key])
  end

  it "should create deploy keys"

  it "should add private files to .gitignore" do
    # %w(config/rails-aws.yml config/rails-aws/ config/aws-keys.yml) 
  end

  it "v2: should update rails projects with a simple config/database.yml"

end
