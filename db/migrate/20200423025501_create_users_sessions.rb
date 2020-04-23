class CreateUsersSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :users_sessions do |t|
      t.integer :user_id, null: false
      t.string :user_type, null: false
      t.string :token, null: false
      t.string :rotation_token
      t.boolean :is_not_deleted, default: true, null: false
      t.datetime :deleted_on
      t.datetime :expires_on, null: false

      t.index [:user_id, :token]
      t.index [:is_not_deleted, :token]
      t.index :token, unique: true

      t.timestamps
    end
  end
end
