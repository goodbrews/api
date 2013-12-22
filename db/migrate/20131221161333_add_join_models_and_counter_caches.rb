require 'app/models/beer'
require 'app/models/brewery'
require 'app/models/event'
require 'app/models/guild'
require 'app/models/ingredient'
require 'app/models/style'

class AddJoinModelsAndCounterCaches < ActiveRecord::Migration
  def change
    # Change join tables to join models
    rename_table :beers_breweries, :beer_breweries
    add_column   :beer_breweries, :id, :primary_key

    rename_table :beers_events, :beer_events
    add_column   :beer_events, :id, :primary_key

    rename_table :beers_ingredients, :beer_ingredients
    add_column   :beer_ingredients, :id, :primary_key

    rename_table :breweries_events, :brewery_events
    add_column   :brewery_events, :id, :primary_key

    rename_table :breweries_guilds, :brewery_guilds
    add_column   :brewery_guilds, :id, :primary_key

    # # Then add and update cache counters
    add_column :beers, :breweries_count,   :integer, default: 0, null: false
    add_column :beers, :events_count,      :integer, default: 0, null: false
    add_column :beers, :ingredients_count, :integer, default: 0, null: false

    Beer.includes(:breweries, :events, :ingredients).find_each do |beer|
      Beer.reset_counters(beer.id, :breweries, :events, :ingredients)
    end

    add_column :breweries, :beers_count,     :integer, default: 0, null: false
    add_column :breweries, :events_count,    :integer, default: 0, null: false
    add_column :breweries, :guilds_count,    :integer, default: 0, null: false
    add_column :breweries, :locations_count, :integer, default: 0, null: false

    Brewery.includes(:beers, :events, :guilds, :locations).find_each do |brewery|
      Brewery.reset_counters(brewery.id, :beers, :events, :guilds, :locations)
    end

    add_column :events, :beers_count,     :integer, default: 0, null: false
    add_column :events, :breweries_count, :integer, default: 0, null: false

    Event.includes(:beers, :breweries).find_each do |event|
      Event.reset_counters(event.id, :beers, :breweries)
    end

    add_column :guilds, :breweries_count, :integer, default: 0, null: false

    Guild.includes(:breweries).find_each do |guild|
      Guild.reset_counters(guild.id, :breweries)
    end

    add_column :ingredients, :beers_count, :integer, default: 0, null: false

    Ingredient.includes(:beers).find_each do |ingredient|
      Ingredient.reset_counters(ingredient.id, :beers)
    end

    add_column :styles, :beers_count, :integer, default: 0, null: false

    Style.includes(:beers).find_each do |style|
      Style.reset_counters(style.id, :beers)
    end
  end
end
