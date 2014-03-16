class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.references :user, null: false
      t.string     :token, null: false
      t.timestamps

      t.index :token, unique: true
      t.index :user_id
    end

    remove_column :users, :auth_token, :string
  end
end
