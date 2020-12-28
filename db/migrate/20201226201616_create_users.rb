class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :github_username, null: false, unique: true
      t.string :email_address, null: false
      t.integer :github_id, null: false, unique: true

      t.timestamps
    end
  end
end
