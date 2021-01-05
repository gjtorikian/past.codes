class DropEmailsFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :email_address
    rename_column :users, :encrypted_gh_token, :encrypted_github_token
  end
end
