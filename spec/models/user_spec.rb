require 'spec_helper'
require Grape.root.join('app', 'models', 'user')

describe User do
  describe 'username' do
    let(:user) { Factory.build(:user, username: nil) }

    it 'must be present' do
      user.should_not be_valid
      user.errors[:username].should include("can't be blank")
    end

    it 'must be unique without regard to casing' do
      other = Factory(:user)
      user.username = other.username.upcase

      user.should_not be_valid
      user.errors[:username].should include('has already been taken')
    end

    it 'must only contain letters, numbers, and underscores' do
      user.username = 'i-am-special!'
      user.should_not be_valid
      user.errors[:username].should include("can only contain letters, numbers, or '_'.")

      user.username = 'i_am_special123'
      user.should be_valid
    end

    it 'must be, at most, 40 characters long' do
      user.username = 'x' * 41
      user.should_not be_valid
      user.errors[:username].should include('is too long (maximum is 40 characters)')

      user.username = 'x' * 40
      user.should be_valid
    end

    %w[admin goodbrews].each do |reserved|
      it "can't be #{reserved}" do
        user.username = reserved
        user.should_not be_valid
        user.errors[:username].should include('is reserved')
      end
    end
  end

  describe 'email' do
    let(:user) { Factory.build(:user, email: nil) }

    it 'must be present' do
      user.should_not be_valid
      user.errors[:email].should include("can't be blank")
    end

    it 'must look like an email address' do
      %w[@ user@ @goodbre user@goodbre].each do |email|
        user.email = email
        user.should_not be_valid
        user.errors[:email].should include('is invalid')
      end

      user.email = 'user@goodbre.ws'
      user.should be_valid
    end

    it 'must be unique without regard to casing' do
      other = Factory(:user)
      user.email = other.email.upcase

      user.should_not be_valid
      user.errors[:email].should include('is already in use')
    end
  end

  describe 'password' do
    let(:user) { Factory.build(:user, password: nil, password_confirmation: nil) }

    it 'must be present' do
      user.should_not be_valid
      user.errors[:password].should include("can't be blank")
    end

    it 'must have a confirmation' do
      user.password = 'supersecret'
      user.should_not be_valid
      user.errors[:password_confirmation].should include("can't be blank")
    end

    it 'must match the confirmation' do
      user.password = 'supersecret'
      user.password_confirmation = 'wrong'

      user.should_not be_valid
      user.errors[:password_confirmation].should include("doesn't match Password")
    end

    it 'must be at least 8 characters long' do
      user.password = 'short'
      user.should_not be_valid
      user.errors[:password].should include("must be between 8 and 50 characters")
    end

    it 'cannot be greater than 50 characters' do
      user.password = 'x' * 51
      user.should_not be_valid
      user.errors[:password].should include("must be between 8 and 50 characters")
    end

    it 'is valid when between 8 and 50 characters' do
      user.password = user.password_confirmation = 'supersecret'
      user.should be_valid
    end

    it 'hashes into a digest' do
      user.password = 'supersecret'
      user.password_digest.should be_present
    end

    context 'on update' do
      subject(:user) { Factory(:user); User.first }

      it 'is not required if unchanged' do
        user.update_attributes(username: 'ever_changing')
        user.should be_valid
      end

      it 'must be confirmed if changed' do
        user.update_with_password(password: 'superchanged').should be_false
        user.errors[:password_confirmation].should include("can't be blank")
      end

      it 'must be accompanied by a current_password if changed' do
        passwords = { password: 'superchanged', password_confirmation: 'superchanged' }
        user.update_with_password(passwords).should be_false
        user.errors[:current_password].should include("can't be blank")
      end

      it 'must be able to authenticate with the current_password if changing' do
        passwords = {
          password: 'superchanged',
          password_confirmation: 'superchanged',
          current_password: 'wrong'
        }

        user.update_with_password(passwords).should be_false
        user.errors[:current_password].should include("is invalid")
      end

      it 'must receive a correct current_password to change the old password' do
        passwords = {
          password: 'superchanged',
          password_confirmation: 'superchanged',
          current_password: 'supersecret'
        }

        user.update_with_password(passwords).should be_true
      end
    end
  end

  describe 'auth_token' do
    let(:user) { Factory(:user) }
    subject { user.auth_token }

    it { should be_present }
  end

  describe '#authenticate' do
    subject(:user) { User.new(password: 'securely') }

    it { expect(user.authenticate('insecurely')).to be_false }
    it { expect(user.authenticate('securely')).to be_true }
  end
end
