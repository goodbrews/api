require 'app/apis/base_api'
require 'app/models/style'
require 'app/presenters/beer_presenter'
require 'app/presenters/style_presenter'

class StylesAPI < BaseAPI
  get { StylePresenter.present(paginate(Style.all), context: self) }

  param :slug do
    let(:style) { Style.from_param(params[:slug]) }

    get { StylePresenter.present(style, context: self) }

    get(:beers) { BeerPresenter.present paginate(style.beers), context: self }
  end
end
