require 'app/apis/base_api'
require 'app/models/user'
require 'app/presenters/beer_presenter'
require 'app/presenters/user_presenter'

class UsersAPI < BaseAPI
  rescue_from(Crepe::Params::Missing) do |e|
    unauthorized! e.message
  end

  post do
    params.permit(*User::PERMISSIBLE_PARAMS)
    user = User.new(params)

    if user.save
      status :created
      { auth_token: user.auth_token }
    else
      error! :unprocessable_entity, user.errors.full_messages
    end
  end

  param :username do
    let(:user) { User.from_param(params[:username]) }

    get { UserPresenter.present(user, context: self) }

    put do
      binding.pry

      unauthorized! unless user == current_user

      params.permit(:current_password, *User::PERMISSIBLE_PARAMS)
      params = params.slice(:current_password, *User::PERMISSIBLE_PARAMS)

      # Use #update_with_password if params[:password] or params[:password_confirmation] are present
      if user.update_with_password(params)
        head :no_content
      else
        error! :unprocessable_entity, user.errors.full_messages
      end
    end

    get :likes do
      beers = user.liked_beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end

    get :dislikes do
      beers = user.disliked_beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end

    get :cellar do
      beers = user.cellared_beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end

    get :hidden do
      unauthorized! unless user == current_user

      beers = user.hidden_beers.includes(:ingredients, :social_media_accounts, :style)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end

    get :similar do
      UserPresenter.present(user.similar_raters, context: self)
    end
  end
end
