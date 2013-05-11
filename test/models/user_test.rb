require 'test_helper'

describe User do
  context 'before creation' do
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
  end

  context 'validating a password' do
    before :each do
      @user = Factory.build(:user, password_confirmation: '')
    end

    context 'upon creation' do
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

      it 'must be at least six characters long' do
        @user.password = 'short'
        @user.wont_be :valid?
        @user.errors[:password].must_include 'must be longer than 6 characters'
      end
    end

    context 'upon updating' do
      before :each do
        @user.password_confirmation = @user.password
        @user.save and @user.reload
      end

      it 'must confirm when changed' do
        @user.password = 'newpassword'
        @user.wont_be :valid?
        @user.errors[:password_confirmation].must_include "doesn't match Password"
      end

      it 'does not have to confirm when it has not changed' do
        @user.name = 'New Name'
        @user.must_be :valid?
      end
    end
  end

  context 'validating a username' do
    before :each do
      @user = Factory.build(:user, username: '')
    end

    it 'cannot be nil' do
      @user.username = nil
      @user.wont_be :valid?
      @user.errors[:username].must_include "can't be blank"
    end

    it 'must be within 1 and 40 characters' do
      @user.wont_be :valid?
      @user.errors[:username].must_include "can't be blank"

      @user.username = 'a'
      @user.must_be :valid?

      @user.username = 'davidcelisdavidcelisdavidcelisdavidcelis'
      @user.must_be :valid?

      @user.username = 'davidcelisdavidcelisdavidcelisdavidcelisd'
      @user.wont_be :valid?
      @user.errors[:username].must_include 'is too long (maximum is 40 characters)'
    end

    it 'cannot be admin, goodbrews, or guest' do
      @user.username = 'admin'
      @user.wont_be :valid?
      @user.errors[:username].must_include 'is reserved'

      @user.username = 'goodbrews'
      @user.wont_be :valid?
      @user.errors[:username].must_include 'is reserved'

      @user.username = 'guest'
      @user.wont_be :valid?
      @user.errors[:username].must_include 'is reserved'
    end

    it 'must only contain letters, numbers, underscores, periods, hyphens, or apostrophes' do
      @user.username = 'spec!al'
      @user.wont_be :valid?

      @user.username = 'fred_jones'
      @user.must_be :valid?
    end

    it 'must be unique' do
      @user.username = 'snowflake'
      @user.save

      another_user = Factory.build(:user, username: 'snowflake')
      another_user.wont_be :valid?

      another_user.username = 'SNOWFLAKE'
      another_user.wont_be :valid?
      another_user.errors[:username].must_include 'has already been taken'
    end
  end
end
