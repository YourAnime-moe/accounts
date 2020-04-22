class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uuid, null: false

      t.string :email, null: false
      t.string :username, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.string :password
      t.string :password_digest

      t.string :color_hex, null: false, default: '000000'
      t.string :type, null: false

      t.boolean :active, null: false, default: false
      t.boolean :blocked, null: false, default: false

      t.index [:email], unique: true
      t.index [:username], unique: true
      t.index [:uuid, :color_hex], unique: true
      t.index [:uuid], unique: true

      t.timestamps
    end
  end
end
