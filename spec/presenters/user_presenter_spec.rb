require 'spec_helper'
require 'app/presenters/user_presenter'

describe UserPresenter do
  let(:users) { [Factory(:user), Factory(:user)] }

  context 'not the current user' do
    let(:context) do
      double.tap do |mock|
        allow(mock).to receive(:current_user).and_return(Factory.build(:user))
      end
    end

    it 'presents a user with a root key' do
      user = users.first
      hash = Digest::MD5.hexdigest(user.email.downcase)

      expected = {
        'user' => {
          'username' => user.username,
          'name'     => user.name,
          'city'     => user.city,
          'region'   => user.region,
          'country'  => user.country,

          'likes'    => user.liked_beers_count,
          'dislikes' => user.liked_beers_count,
          'cellar'   => user.bookmarked_beers_count,

          '_links' => {
            'self'     => { 'href' => "/users/#{user.to_param}" },
            'likes'    => { 'href' => "/users/#{user.to_param}/likes" },
            'dislikes' => { 'href' => "/users/#{user.to_param}/dislikes" },
            'cellar'   => { 'href' => "/users/#{user.to_param}/cellar" },
            'similar'  => { 'href' => "/users/#{user.to_param}/similar" },
            'gravatar' => {
              'href' =>  "https://secure.gravatar.com/avatar/#{hash}.jpg?s={size}",
              templated: true,
              size:      '1..2048'
            }
          }
        }
      }

      hash = UserPresenter.present(users.first, context: context)

      expect(hash).to eq(expected)
    end

    it 'presents an array of users without root keys' do
      expected = [
        UserPresenter.present(users.first, context: context)['user'],
        UserPresenter.present(users.last,  context: context)['user']
      ]

      expect(UserPresenter.present(users, context: context)).to eq(expected)
    end
  end

  context 'with the current user' do
    let(:user) { users.first }
    let(:context) do
      double.tap do |mock|
        allow(mock).to receive(:current_user).and_return(user)
      end
    end

    it 'presents a user with a root key' do
      hash = Digest::MD5.hexdigest(user.email.downcase)

      expected = {
        'user' => {
          'username' => user.username,
          'email'    => user.email,
          'name'     => user.name,
          'city'     => user.city,
          'region'   => user.region,
          'country'  => user.country,

          'likes'    => user.liked_beers_count,
          'dislikes' => user.liked_beers_count,
          'cellar'   => user.bookmarked_beers_count,
          'hidden'   => user.hidden_beers_count,

          '_links' => {
            'self'     => { 'href' => "/users/#{user.to_param}" },
            'likes'    => { 'href' => "/users/#{user.to_param}/likes" },
            'dislikes' => { 'href' => "/users/#{user.to_param}/dislikes" },
            'cellar'   => { 'href' => "/users/#{user.to_param}/cellar" },
            'hidden'   => { 'href' => "/users/#{user.to_param}/hidden" },
            'similar'  => { 'href' => "/users/#{user.to_param}/similar" },

            'gravatar' => {
              'href' =>  "https://secure.gravatar.com/avatar/#{hash}.jpg?s={size}",
              templated: true,
              size:      '1..2048'
            }
          }
        }
      }

      hash = UserPresenter.present(users.first, context: context)

      expect(hash).to eq(expected)
    end
  end
end
