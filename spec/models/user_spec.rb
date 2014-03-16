require 'spec_helper'
require 'app/models/user'

describe User do
  it 'is recommended beers' do
    expect(Recommendable.config.ratable_classes).to include(Beer)
    expect(Recommendable.config.user_class).to eq(User)
  end

  describe 'username' do
    let(:user) { Factory.build(:user, username: nil) }

    it 'must be present' do
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'must be unique without regard to casing' do
      other = Factory(:user)
      user.username = other.username.upcase

      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('has already been taken')
    end

    it 'must only contain letters, numbers, and underscores' do
      user.username = 'i-am-special!'
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can only contain letters, numbers, '-', or '_'.")

      user.username = 'i_am-special123'
      expect(user).to be_valid
    end

    it 'must be, at most, 40 characters long' do
      user.username = 'x' * 41
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is too long (maximum is 40 characters)')

      user.username = 'x' * 40
      expect(user).to be_valid
    end

    %w[admin goodbrews].each do |reserved|
      it "can't be #{reserved}" do
        user.username = reserved
        expect(user).not_to be_valid
        expect(user.errors[:username]).to include('is reserved')
      end
    end
  end

  describe 'email' do
    let(:user) { Factory.build(:user, email: nil) }

    it 'must be present' do
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'must look like an email address' do
      %w[@ user@ @goodbre user@goodbre].each do |email|
        user.email = email
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end

      user.email = 'user@goodbre.ws'
      expect(user).to be_valid
    end

    it 'must be unique without regard to casing' do
      other = Factory(:user)
      user.email = other.email.upcase

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is already in use')
    end
  end

  describe 'password' do
    let(:user) { Factory.build(:user, password: nil, password_confirmation: nil) }

    it 'must be present' do
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'must have a confirmation' do
      user.password = 'supersecret'
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("can't be blank")
    end

    it 'must match the confirmation' do
      user.password = 'supersecret'
      user.password_confirmation = 'wrong'

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it 'must be at least 8 characters long' do
      user.password = 'short'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must be between 8 and 50 characters")
    end

    it 'cannot be greater than 50 characters' do
      user.password = 'x' * 51
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("must be between 8 and 50 characters")
    end

    it 'is valid when between 8 and 50 characters' do
      user.password = user.password_confirmation = 'supersecret'
      expect(user).to be_valid
    end

    it 'hashes into a digest' do
      user.password = 'supersecret'
      expect(user.password_digest).to be_present
    end

    context 'on update' do
      subject(:user) { Factory(:user); User.first }

      it 'is not required if unchanged' do
        user.update_attributes(username: 'ever_changing')
        expect(user).to be_valid
      end

      it 'must be confirmed if changed' do
        expect(user.update_with_password(password: 'superchanged')).to be_false
        expect(user.errors[:password_confirmation]).to include("can't be blank")
      end

      it 'must be accompanied by a current_password if changed' do
        passwords = { password: 'superchanged', password_confirmation: 'superchanged' }
        expect(user.update_with_password(passwords)).to be_false
        expect(user.errors[:current_password]).to include("can't be blank")
      end

      it 'must be able to authenticate with the current_password if changing' do
        passwords = {
          password: 'superchanged',
          password_confirmation: 'superchanged',
          current_password: 'wrong'
        }

        expect(user.update_with_password(passwords)).to be_false
        expect(user.errors[:current_password]).to include("is invalid")
      end

      it 'must receive a correct current_password to change the old password' do
        passwords = {
          password: 'superchanged',
          password_confirmation: 'superchanged',
          current_password: 'supersecret'
        }

        expect(user.update_with_password(passwords)).to be_true
      end
    end
  end

  describe 'auth_tokens' do
    let(:user) { Factory(:user) }
    subject(:it) { user.auth_tokens }

    it 'is present' do
      expect(it).to be_present
    end
  end

  describe '#authenticate' do
    subject(:user) { User.new(password: 'securely') }

    it 'returns false with a bad password' do
      expect(user.authenticate('insecurely')).to be_false
    end

    it 'returns true with a good password' do
      expect(user.authenticate('securely')).to be_true
    end
  end

  describe '#send_welcome_email' do
    let(:user) { Factory.build(:user) }
    before { user.save }

    it { should have_sent_email.from('brewmaster@goodbre.ws') }
    it { should have_sent_email.to(user.email) }
    it { should have_sent_email.matching_body(/Hey there, #{user.display_name}!/) }
  end

  describe '#send_password_reset' do
    subject(:user) { Factory(:user) }

    before { user.send_password_reset }

    it 'should have a password_reset_token' do
      expect(user.password_reset_token).not_to be_nil
    end

    it 'should have a password_reset_sent_at' do
      expect(user.password_reset_sent_at).not_to be_nil
    end

    it { should have_sent_email.from('brewmaster@goodbre.ws') }
    it { should have_sent_email.to(user.email) }
    it { should have_sent_email.matching_body(%r{https://goodbre.ws/reset_password/#{user.password_reset_token}}) }
  end
end
