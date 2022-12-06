class CreateExternalOauthGrants < ActiveRecord::Migration[6.1]
  def change
    create_table :external_oauth_grants do |t|
      t.string :grant_name # ie: discord
      t.string :grant_user_id # ie: the user ID on the platform if applicable
      t.string :grant_type # ie: code
      t.string :access_token
      t.string :refresh_token
      t.string :scope
      t.datetime :expires_on
      t.boolean :is_not_deleted, default: true, null: false
      t.belongs_to :user
      t.timestamps
    end
  end
end
