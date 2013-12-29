require 'spec_helper'
require 'app/presenters/style_presenter'

describe StylePresenter do
  let(:styles) { [Factory(:style), Factory(:style)] }

  it 'presents an style with a root key' do
    style = styles.first

    expected = {
      'style' => {
        'name'        => style.name,
        'category'    => style.category,
        'description' => style.description,

        'min_abv'              => style.min_abv,
        'max_abv'              => style.max_abv,
        'min_ibu'              => style.min_ibu,
        'max_ibu'              => style.max_ibu,
        'min_original_gravity' => style.min_original_gravity,
        'max_original_gravity' => style.max_original_gravity,
        'min_final_gravity'    => style.min_final_gravity,
        'max_final_gravity'    => style.max_final_gravity,

        'beers' => style.beers.count,

        '_links' => {
          'self'  => { 'href' => "/styles/#{style.to_param}" },
          'beers' => { 'href' => "/styles/#{style.to_param}/beers" }
        }
      }
    }

    hash = StylePresenter.present(styles.first, context: self)

    expect(hash).to eq(expected)
  end
end

describe StylesPresenter do
  let(:context) do
    double.tap do |d|
      allow(d).to receive(:params).and_return({})
    end
  end

  before { 2.times { Factory(:style) } }

  it 'presents a collection of styles' do
    styles = Style.all
    expected = {
      'count' => 2,
      'styles' => [
        StylePresenter.new(styles.first, context: context, root: nil).present,
        StylePresenter.new(styles.last,  context: context, root: nil).present
      ]
    }

    presented = StylesPresenter.new(styles, context: context, root: nil).present

    expect(presented).to eq(expected)
  end
end

