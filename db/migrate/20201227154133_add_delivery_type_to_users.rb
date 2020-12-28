class AddDeliveryTypeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :frequency, :integer, null: false, default: 0

    add_index :users, :frequency
  end
end
