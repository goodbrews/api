require 'app/apis/base_api'
require 'app/models/style'
require 'app/presenters/beer_presenter'
require 'app/presenters/style_presenter'

class StylesAPI < BaseAPI
  get { StylesPresenter.new(Style.all, context: self, root: nil).present }

  param :slug do
    let(:style) { Style.from_param(params[:slug]) }

    get { StylePresenter.new(style, context: self).present }

    get :beers do
      BeersPresenter.new(style.beers, context: self, root: nil).present
    end
  end
end
