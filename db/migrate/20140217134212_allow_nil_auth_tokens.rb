class AllowNilAuthTokens < ActiveRecord::Migration
  def change
    change_column :users, :auth_token, :string, null: true, default: nil
  end
end
