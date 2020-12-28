class AddFieldsAndValidationToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :users, :encrypted_gh_token, :string, null: false
    add_index :users, :uid, unique: true, algorithm: :concurrently
  end
end
