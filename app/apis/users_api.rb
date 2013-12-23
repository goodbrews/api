require 'app/apis/base_api'
require 'app/models/user'
require 'app/presenters/beer_presenter'
require 'app/presenters/user_presenter'

class UsersAPI < BaseAPI
  param :username do
    let(:user) { User.from_param(params[:username]) }

    get { UserPresenter.present(user, context: self) }

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
