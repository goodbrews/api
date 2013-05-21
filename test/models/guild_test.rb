require 'test_helper'

describe Guild do
  it 'must be socialable' do
    Guild.ancestors.must_include Socialable
  end

  context 'before destruction' do
    before do
      @guild = Factory(:guild)
    end

    it 'must clear Brewery join records' do
      brewery = Factory(:brewery)
      brewery.guilds << @guild

      @guild.reload and brewery.reload

      @guild.destroy
      brewery.reload

      brewery.id.wont_be_nil
      brewery.guilds.wont_include(@guild)
    end
  end
end
