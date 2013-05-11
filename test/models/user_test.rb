require "test_helper"

describe User do
  before :each do
    @user = Factory.build(:user)
  end

  describe "during creation" do
    it "must encrypt a password into a password_digest" do
      @user = Factory.build(:user, password: nil, password_confirmation: nil)

      @user.password = 'supersecret'
      @user.password_digest.wont_be_nil
    end

    it "must generate an auth_token before saving" do
      @user.auth_token.must_be_nil

      @user.save
      @user.auth_token.wont_be_nil
    end
  end
end
