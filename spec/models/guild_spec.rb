require 'spec_helper'
require 'app/models/guild'
require 'models/shared_examples/join_records'
require 'models/shared_examples/socialable'

describe Guild do
  it_behaves_like 'a socialable'
  it_behaves_like 'something that has join records'

  describe '#to_param' do
    it 'returns the brewerydb_id' do
      guild = Factory.build(:guild)
      expect(guild.to_param).to eq(guild.brewerydb_id)
    end
  end

  describe '.from_param' do
    it 'raises an ActiveRecord::RecordNotFound if no guild exists' do
      expect { Guild.from_param('no') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'takes a brewerydb_id to find an Guild using .from_param' do
      guild = Factory(:guild)
      expect(Guild.from_param(guild.brewerydb_id)).to eq(guild)
    end
  end
end
