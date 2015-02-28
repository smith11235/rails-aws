require 'spec_helper'

describe  "Config File Format" do

  let(:default_config) do
    <<-END_OF_CONFIG
      account_id: 180190769793
      region: us_east_1 
      ami: ami-8afb51e2
      project_name:
        git_repo: https://github.com/smith11235/rails-aws.git
        default:
          account_id: 180190769793
          region: us_east_1 
          ami: ami-8afb51e2
          app:
            instance_type: t1.micro
          database: 
            instance_type: local # sqlite
    END_OF_CONFIG
  end

  let(:tiered_config) do
    <<-END_OF_CONFIG
      project_name:
        git_repo: https://github.com/smith11235/rails-aws.git
        default:
          account_id: 180190769793
          region: us_east_1 
          ami: ami-8afb51e2
          app:
            instance_type: t1.micro
          database: 
            instance_type: local
            db_type: sqlite
        master: 
          app:
            instance_type: m3.medium
          database: 
            instance_type: rds.t2.medium
            db_type: postgres
          domain: rails-aws.com
    END_OF_CONFIG
  end

  describe "Default Config" do
    it "should validate against schema"
  end

  describe "Tiered Config" do
    it "should validate against schema"
    it "should override specific default values"
    it "should fall back to defaults for all non overidden values"
  end

end
