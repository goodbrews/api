require 'test_helper'

describe User do
  before :each do
    @user = Factory.build(:user)
  end

  it 'must encrypt a password into a password_digest' do
    @user = Factory.build(:user, password: nil, password_confirmation: nil)

    @user.password = 'supersecret'
    @user.password_digest.wont_be_nil
  end

  it 'must generate an auth_token before creation' do
    @user.auth_token.must_be_nil

    @user.save
    @user.auth_token.wont_be_nil
  end

  context 'validating a password' do
    context 'upon creation' do
      before :each do
        @user = Factory.build(:user, password_confirmation: '')
      end

      it 'must not have a blank password_confirmation' do
        @user.wont_be :valid?
        @user.errors[:password_confirmation].must_include "can't be blank"
      end

      it 'must have a matching password_confirmation' do
        @user.password_confirmation = 'notthesame'
        @user.wont_be :valid?
        @user.errors[:password_confirmation].must_include "doesn't match Password"

        @user.password_confirmation = @user.password
        @user.must_be :valid?
      end

      it 'must have a password at least six characters long' do
        @user.password = 'short'
        @user.wont_be :valid?
        @user.errors[:password].must_include 'must be longer than 6 characters'
      end
    end

    context 'upon updating' do
      it 'must confirm a password when it has changed' do
        @user.save and @user.reload

        @user.password = 'newpassword'
        @user.wont_be :valid?
        @user.errors[:password_confirmation].must_include "doesn't match Password"
      end

      it 'does not have to confirm a password when it has not changed' do
        @user.save and @user.reload

        @user.name = 'New Name'
        @user.must_be :valid?
      end
    end
  end
end
