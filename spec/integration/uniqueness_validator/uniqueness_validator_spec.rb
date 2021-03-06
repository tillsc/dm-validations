require 'spec_helper'
require 'integration/uniqueness_validator/spec_helper'


describe 'uniqueness_validator/uniqueness_validator_spec' do

  describe 'DataMapper::Validations::Fixtures::Department' do
    before :all do
      DataMapper::Validations::Fixtures::Department.destroy!

      DataMapper::Validations::Fixtures::Department.create(:name => "HR").should be_saved
    end

    describe "with unique name" do
      before do
        @model = DataMapper::Validations::Fixtures::Department.new(:name => "R & D")
      end

      it_should_behave_like "valid model"
    end

    describe "with a duplicate name" do
      before do
        @model = DataMapper::Validations::Fixtures::Department.new(:name => "HR")
      end

      it_should_behave_like "invalid model"
    end
  end

  describe 'DataMapper::Validations::Fixtures::SpecialDepartment' do
    before :all do
      DataMapper::Validations::Fixtures::Department.destroy!

      DataMapper::Validations::Fixtures::Department.create(:name => "HR").should be_saved
    end

    describe "with a duplicate name" do
      before do
        @model = DataMapper::Validations::Fixtures::SpecialDepartment.new(:name => "HR")
      end

      it_should_behave_like "invalid model"
    end
  end

  describe 'DataMapper::Validations::Fixtures::SpecialDepartment' do
    before :all do
      DataMapper::Validations::Fixtures::Department.destroy!

      DataMapper::Validations::Fixtures::SpecialDepartment.create(:name => "HR", :special_id => "1234").should be_saved
    end

    describe "with a duplicate special_id" do
      before do
        @model = DataMapper::Validations::Fixtures::SpecialDepartment.new(:name => "Other Dept.", :special_id => "1234")
      end

      it_should_behave_like "invalid model"
    end
  end

  describe 'DataMapper::Validations::Fixtures::VerySpecialDepartment' do
    before :all do
      DataMapper::Validations::Fixtures::Department.destroy!

      DataMapper::Validations::Fixtures::SpecialDepartment.create(:name => "HR", :special_id => "1234").should be_saved
    end

    describe "with a special_id also used by a SpecialDepartment" do
      before do
        @model = DataMapper::Validations::Fixtures::VerySpecialDepartment.new(:name => "Some Very Special Other Dept.", :special_id => "1234")
      end

      it_should_behave_like "valid model"
    end
  end

  describe 'DataMapper::Validations::Fixtures::Organisation' do
    before :all do
      DataMapper::Validations::Fixtures::Organisation.destroy!

      @model = DataMapper.repository do
        DataMapper::Validations::Fixtures::Organisation.create(:name => 'Apple', :domain => 'apple.com')
      end
    end

    describe "with missing domain" do
      before do
        @model.domain = nil
      end

      it_should_behave_like "valid model"
    end

    describe "with a duplicate domain" do
      before do
        @model = DataMapper::Validations::Fixtures::Organisation.new(:name => 'Fake Apple', :domain => 'apple.com')
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.valid?
        @model.errors.on(:domain).should == [ 'Domain is already taken' ]
      end
    end

    it "shouldn't fail on itself when checking for records with identical fields" do
      @model.name = "Steve Job's Pony Express"
      @model.should be_valid
    end
  end

  describe 'DataMapper::Validations::Fixtures::User' do
    before :all do
      DataMapper::Validations::Fixtures::Organisation.destroy!
      DataMapper::Validations::Fixtures::Department.destroy!
      DataMapper::Validations::Fixtures::User.destroy!

      DataMapper.repository do
        @organization = DataMapper::Validations::Fixtures::Organisation.create(:name => 'Org 101', :domain => '101')
        @dept         = DataMapper::Validations::Fixtures::Department.create(:name => 'accounting')
        @user         = DataMapper::Validations::Fixtures::User.create(:organisation => @organization, :user_name => 'guy', :department => @dept)

        @organization.should be_saved
        @dept.should be_saved
        @user.should be_saved
      end
    end

    describe "with username not valid across the organization" do
      before do
        @model = DataMapper::Validations::Fixtures::User.new(:organisation => @organization, :user_name => 'guy')
      end

      it "is not valid for signing up" do
        @model.should_not be_valid_for_signing_up_for_organization_account
      end

      it "has a meaningful error message" do
        @model.valid?(:signing_up_for_organization_account)
        @model.errors.on(:user_name).should == [ 'User name is already taken' ]
      end
    end


    describe "with username not valid across the department" do
      before do
        @model = DataMapper::Validations::Fixtures::User.new(:user_name => 'guy', :department => @dept)
      end

      it "is not valid for setting up the account" do
        @model.should_not be_valid_for_signing_up_for_department_account
      end

      it "has a meaningful error message" do
        @model.valid?(:signing_up_for_department_account)
        @model.errors.on(:user_name).should == [ 'User name is already taken' ]
      end
    end
  end

end
