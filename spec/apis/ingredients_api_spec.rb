require 'spec_helper'
require 'app/apis/ingredients_api'

describe IngredientsAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
    end
  end

  context '/ingredients' do
    it 'returns an empty array' do
      get '/ingredients'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of ingredients as JSON' do
      ingredient = Factory(:ingredient)
      body = IngredientPresenter.present([ingredient], context: context)

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

          expect(last_response.body).to eq('[]')
        end

        it 'returns beers as JSON' do
          ingredient.beers << Factory(:beer)
          body = BeerPresenter.present(ingredient.beers.reload, context: context)

          get "/ingredients/#{ingredient.to_param}/beers"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
