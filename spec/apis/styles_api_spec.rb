require 'spec_helper'
require 'app/apis/api'

describe StylesAPI do
  def app
    Goodbrews::API
  end

  let(:context) do
    double.tap do |d|
      allow(d).to receive(:authorized?).and_return(false)
      allow(d).to receive(:params).and_return({})
    end
  end

  context '/styles' do
    it 'returns an empty array' do
      get '/styles'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    it 'returns a list of styles as JSON' do
      style = Factory(:style)
      body = StylePresenter.present([style], context: context)

      get '/styles'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(body.to_json)
    end
  end

  context '/styles/:slug' do
    context 'without an existing style' do
      it 'returns a 404' do
        get '/styles/nothing-here'

        expect(last_response.status).to eq(404)
      end
    end

    context 'with an existing style' do
      let(:style) { Factory(:style) }

      it 'returns an existing style as json' do
        body = StylePresenter.present(style, context: context)

        get "/styles/#{style.to_param}"

        expect(last_response.body).to eq(body.to_json)
      end

      context '/beers' do
        it 'returns an empty array' do
          get "/styles/#{style.to_param}/beers"

          expect(last_response.body).to eq('{"count":0,"beers":[]}')
        end

        it 'returns beers as JSON' do
          Factory(:beer, style: style)
          body = BeersPresenter.new(style.beers.reload, context: context, root: nil).present

          get "/styles/#{style.to_param}/beers"
          expect(last_response.body).to eq(body.to_json)
        end
      end
    end
  end
end
