class CreateConnextApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :connext_applications do |t|
      t.string :name, null: false
      t.string :uuid, null: false
      t.string :secret, null: false
      t.string :redirect_uri, null: false

      t.index :uuid, unique: true

      t.timestamps
    end
  end
end
