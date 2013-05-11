class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :email,           null: false
      t.string   :username,        null: false
      t.string   :password_digest, null: false
      t.string   :auth_token,      null: false

      t.string   :password_reset_token
      t.datetime :password_reset_token_sent_at

      t.string   :name
      t.string   :city
      t.string   :region
      t.string   :country
      t.float    :latitude
      t.float    :longitude

      t.index    :email,                unique: true
      t.index    :username,             unique: true
      t.index    :auth_token,           unique: true
      t.index    :password_reset_token, unique: true

      t.timestamps
    end
  end
end
