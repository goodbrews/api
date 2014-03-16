require 'spec_helper'
require 'app/models/auth_token'

describe AuthToken do
  let(:auth_token) { Factory(:auth_token) }

  describe '#token' do
    subject { auth_token.token }

    it { should be_present }
  end

  describe '#to_json' do
    subject { auth_token.to_json }

    it { should eq(%({"auth_token":"#{auth_token}"}))}
  end
end
