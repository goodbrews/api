require "test_helper"

describe User do
  before :each do
    @user = Factory.build(:user, password: nil)
  end

  it "must encrypt a password into a password_digest" do
    @user.password.must_be_nil
    @user.password_digest.must_be_nil

    @user.password = 'supersecret'
    @user.password_digest.wont_be_nil
  end
end
