class Beer < ActiveRecord::Base
  def to_param
    brewerydb_id
  end
end
