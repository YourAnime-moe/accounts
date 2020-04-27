class CreateConnextApplicationTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :connext_application_tokens do |t|
      t.bigint :application_id, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_in
      t.datetime :revoked_at
      t.string :scopes

      t.index :token, unique: true
      t.index :refresh_token, unique: true

      t.timestamps
    end
  end
end
