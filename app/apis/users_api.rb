require 'app/apis/base_api'
require 'app/models/user'
require 'app/presenters/beer_presenter'
require 'app/presenters/user_presenter'

class UsersAPI < BaseAPI
  post do
    user_params = params.require(:user).permit(*User::PERMISSIBLE_PARAMS)
    user = User.new(user_params)

    if user.save
      status :created
      { auth_token: user.auth_token }
    else
      error! :unprocessable_entity, user.errors.full_messages
    end
  end

  scope :reset_password do
    post do
      params.require(:email)
      user = User.find_by(email: params[:email])

      user.send_password_reset if user

      { message: 'Email sent with password reset instructions.' }
    end

    param :password_reset_token do
      let(:user) { User.find_by!(password_reset_token: params[:password_reset_token]) }

      post do
        params.require(:password) and params.require(:password_confirmation)
        params.permit(:password, :password_confirmation, :password_reset_token)
        user_params = params.to_h.with_indifferent_access
        user_params[:password_reset_token] = nil

        if user.password_reset_sent_at > 2.hours.ago
          user.update_attributes(user_params)
          { message: 'Your password has been reset.' }
        else
          { error: { message: 'Your password reset has expired.'} }
        end
      end
    end
  end

  param :username do
    let(:user) { User.from_param(params[:username]) }

    get { UserPresenter.new(user, context: self).present }

    put do
      unauthorized! unless user == current_user
      user_params = params.require(:user).permit(:current_password, *User::PERMISSIBLE_PARAMS)
      user_params = params[:user].to_h.with_indifferent_access

      if user.update_with_password(user_params)
        head :no_content
      else
        error! :unprocessable_entity, user.errors.full_messages
      end
    end

    get :likes do
      BeersPresenter.new(user.liked_beers, context: self, root: nil).present
    end

    get :dislikes do
      BeersPresenter.new(user.disliked_beers, context: self, root: nil).present
    end

    get :cellar do
      BeersPresenter.new(user.cellared_beers, context: self, root: nil).present
    end

    get :hidden do
      unauthorized! unless user == current_user

      BeersPresenter.new(user.hidden_beers, context: self, root: nil).present
    end

    get :recommendations do
      unauthorized! unless user == current_user

      BeersPresenter.new(user.recommended_beers, context: self, root: nil).present
    end

    get(:similar) { UsersPresenter.new(user.similar_raters, context: self, root: nil).present }
  end
end
