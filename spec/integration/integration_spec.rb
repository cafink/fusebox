require 'spec_helper'

# These specs run all the commands on your *live* Fusemail account.  Fusemail
# unfortunately does not provide a "test mode" in its API, which makes these
# tests difficult to run.  These tests are non-atomic, and each test relies
# on the previous test to set up the data, and a later test to clean up.
# Additionally, some tests like "order" have a lengthy "sleep" delay to allow
# the data its necessary propagation time for it to be available to subsequent
# tests.  Tests *may* fail if fusemail's servers are overloaded and the data
# has not propagated.
#
# If you have any ideas for improving these tests, please feel free to refactor
# or drop suggestions.
describe Fusebox::Request do

  before(:all) do
    @fixtures = YAML.load(File.read(File.expand_path('~/.fusemail.yaml')))['spec']
    raise "Integration tests require 'spec' properties defined in ~/.fusemail.yaml" unless @fixtures
  end

  describe "commands" do

    describe "order" do
      it "should not be successful when adding existing account" do
        @response = Fusebox::Request.new.order(:account_type => @fixtures['group_account_type'], :user => 'postmaster@mudbugmedia.com', :password => SecureRandom.hex)
        @response.detail.should match('already exists')
        @response.success?.should == false
      end

      it "should be successful when adding new group account" do
        @response = Fusebox::Request.new.order(:account_type => @fixtures['group_account_type'], :user => "postmaster@#{SPEC_DOMAIN}", :password => SecureRandom.hex, :first_name => 'fusebox rspec sandbox', :last_name => '(delete me)')
        @response.detail.should match('Order Created Succesfully')
        @response.success?.should == true
        sleep SLEEP_DURATION # Let fusemail catch up.. hopefully.
      end

      it "should be successful when adding group subaccounts" do
        @response = Fusebox::Request.new.order(:account_type => 'group_subaccount', :group_parent => "postmaster@#{SPEC_DOMAIN}", :user => "user@#{SPEC_DOMAIN}", :password => SecureRandom.hex, :first_name => 'fusebox rspec sandbox', :last_name => '(delete me)')
        @response.detail.should match('Order Created Succesfully')
        @response.success?.should == true
      end
    end

    describe "modify" do
      it "should be successful" do
        @response = Fusebox::Request.new.modify(:user => "postmaster@#{SPEC_DOMAIN}", :first_name => 'fusebox rspec sandbox modified')
        @response.detail.should match('modification complete')
        @response.success?.should == true
      end
    end

    describe "report" do
      it "should be return a array of hash results" do
        @response = Fusebox::Request.new.report('user' => "postmaster@#{SPEC_DOMAIN}", 'group_subaccount' => 'yes')
        @response.records.should be_instance_of(Array)
        @response.records.first.should be_instance_of(Hash)
        @response.records.map { |r| r[:username] }.should include("postmaster@#{SPEC_DOMAIN}")
        @response.success?.should == true
      end
    end

    describe "adddomain" do
      it "should be successful" do
        @response = Fusebox::Request.new.adddomain(:domain => SECONDARY_DOMAIN, :user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match('Domain was added')
        @response.success?.should == true
      end
    end

    describe "checkdomain" do
      it "should not be successful for existing domains" do
        @response = Fusebox::Request.new.checkdomain(:domain => SECONDARY_DOMAIN)
        @response.detail.should match('already exists')
        @response.success?.should == false
      end

      it "should be successful for new domains" do
        @response = Fusebox::Request.new.checkdomain(:domain => SecureRandom.hex(4) + '.example.com')
        @response.detail.should match('Domain is Available')
        @response.success?.should == true
      end
    end

    describe "removedomain" do
      it "should be successful" do
        @response = Fusebox::Request.new.removedomain(:domain => SECONDARY_DOMAIN)
        @response.detail.should match('Domain was removed')
        @response.success?.should == true
      end
    end


    describe "addforward" do
      it "should be successful" do
        @response = Fusebox::Request.new.addforward(:forward_what => FORWARD, :forward_to => "postmaster@#{SPEC_DOMAIN}", :user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match('Your forwarder has been successfully submitted')
        @response.success?.should == true
      end
    end

    describe "getforward" do
      it "should be successful for existing forwards" do
        @response = Fusebox::Request.new.getforward(:forward_what => FORWARD, :user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match("postmaster@#{SPEC_DOMAIN}")
        @response.success?.should == true
      end
    end

    describe "removeforward" do
      it "should be successful" do
        @response = Fusebox::Request.new.removeforward(:forward_what => FORWARD, :forward_to => "postmaster@#{SPEC_DOMAIN}", :user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match('Your forwarder has been successfully removed')
        @response.success?.should == true
      end
    end


    describe "checkalias" do
      it "should not be successful for existing aliases" do
        @response = Fusebox::Request.new.checkalias(:alias => "postmaster@#{SPEC_DOMAIN}")
        @response.should be_instance_of(Fusebox::Response)
        @response.detail.should match('already taken')
        @response.success?.should == false
      end

      it "should be successful for new aliases" do
        @response = Fusebox::Request.new.checkalias(:alias => SecureRandom.hex + "@#{SPEC_DOMAIN}")
        @response.detail.should match('Alias is Available')
        @response.success?.should == true
      end
    end

    describe "suspend" do
      it "should be successful when suspending existing accounts" do
        @response = Fusebox::Request.new.suspend(:user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match('Account Succesfully Suspended')
        @response.success?.should == true
      end
    end

    describe "enable" do
      it "should be successful when enabling suspended accounts" do
        @response = Fusebox::Request.new.enable(:user => "postmaster@#{SPEC_DOMAIN}")
        @response.detail.should match('Account Successfully Enabled')
        @response.success?.should == true
      end
    end

    describe "terminate" do
      it "should not be successful when purging non-existing accounts" do
        @response = Fusebox::Request.new.terminate(:user => SecureRandom.hex + "@#{SPEC_DOMAIN}", :purge => true)
        @response.detail.should match('Terminate account failed Could not find user')
        @response.success?.should == false
      end

      it "should be successful purge existing accounts" do
        @response = Fusebox::Request.new.terminate(:user => "postmaster@#{SPEC_DOMAIN}", :purge => true)
        @response.detail.should match('Account Successfully Terminated')
        @response.success?.should == true
      end
    end

  end
end
