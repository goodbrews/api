require 'app/apis/base_api'
require 'app/models/style'
require 'app/presenters/beer_presenter'
require 'app/presenters/style_presenter'

class StylesAPI < BaseAPI
  get { StylePresenter.present(paginate(Style.all), context: self) }

  param :slug do
    let(:style) { Style.from_param(params[:slug]) }

    get { StylePresenter.present(style, context: self) }

    get :beers do
      beers = style.beers.includes(:ingredients, :social_media_accounts)
      beers = paginate(beers)

      BeerPresenter.present(beers, context: self)
    end
  end
end
