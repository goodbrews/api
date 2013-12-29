require 'spec_helper'
require 'app/apis/api'

describe IngredientsAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  context '/ingredients' do
    it 'returns an empty array' do
      get '/ingredients'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('{"count":0,"ingredients":[]}')
    end

    it 'returns a list of ingredients as JSON' do
      ingredient = Factory(:ingredient)
      body = IngredientsPresenter.new(Ingredient.all, context: context, root: nil).present

      get '/ingredients'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/ingredients/:id' do
    context 'without an existing event' do
      it 'returns a 404' do
        get '/ingredients/1'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing ingredient' do
      let(:ingredient) { Factory(:ingredient) }

      it 'returns an existing ingredient as json' do
        body = IngredientPresenter.present(ingredient, context: context)

        get "/ingredients/#{ingredient.to_param}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/beers' do
        it 'returns an empty array' do
          get "/ingredients/#{ingredient.to_param}/beers"

          expect(last_response.body).to eq('{"count":0,"beers":[]}')
        end

        it 'returns beers as JSON' do
          ingredient.beers << Factory(:beer)
          body = BeersPresenter.new(ingredient.beers.reload, context: context, root: nil).present

          get "/ingredients/#{ingredient.to_param}/beers"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
