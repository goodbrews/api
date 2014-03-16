class CreatePgSearchExtensions < ActiveRecord::Migration
  def up
    enable_extension :pg_trgm
    enable_extension :fuzzystrmatch
    enable_extension :unaccent
  end

  def down
    disable_extension :unaccent
    disable_extension :fuzzystrmatch
    disable_extension :pg_trgm
  end
end
