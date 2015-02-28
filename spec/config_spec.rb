require 'spec_helper'

describe RailsAws::Config do

  let(:default_config) do
    <<-END_OF_CONFIG
      my_project_name:
        git_repo: https://github.com/smith11235/rails-aws.git
        default:
          account_id: 180190769793
    END_OF_CONFIG
  end

  let(:tiered_config) do
    <<-END_OF_CONFIG
      my_other_project_name:
        git_repo: https://github.com/smith11235/rails-aws.git
        default:
          account_id: 180190769793
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
    let(:config){ 
      config = RailsAws::Config.new default_config
    }

    it "should validate against the schema"
    
    it "should have a project" do
      expect { config.set_project("my_project_name") }.to_not raise_error
    end

    it "should fail for an unknown project" do
      expect { config.set_project("fake_project_name") }.to raise_error
    end

    it "should have a git_repo" do
      config.set_project("my_project_name")
      expect(config.project).to have_key("git_repo")
    end

    it "should have all default config values for a random branch" do
      config.set_project("my_project_name")
      config.set_branch("random_branch_name")
      branch = config.branch
      branch.delete "account_id"
      expect(branch).to eql(config.default_branch_settings)
    end

    it "should have an account id" do
      config.set_project("my_project_name")
      config.set_branch("random_branch_name")
      expect(config.branch).to have_key("account_id")
    end

  end

  describe "Tiered Config and Overrides" do
    let(:config){ 
      config = RailsAws::Config.new tiered_config
    }

    it "should validate against schema"

    it "should override specific default values" do
      config.set_project("my_other_project_name")
      config.set_branch("master")
      branch = config.branch
      expect(branch['app']['instance_type']).to eq("m3.medium")
      expect(branch['database']['instance_type']).to eq("rds.t2.medium")
      expect(branch['database']['db_type']).to eq("postgres")
      expect(branch['domain']).to eq("rails-aws.com")
    end

  end

  describe "Multiple project support" do
    it "should allow multiple projects" do
      config = RailsAws::Config.new default_config + "\n" + tiered_config
      expect(config.projects).to eql(["my_other_project_name","my_project_name"])
    end
  end

end
