class AddDeliveryTypeToUsers < ActiveRecord::Migration[6.1]
  def change
    create_enum :delivery_type, %w(weekly monthly)
    add_column :users, :frequency, :delivery_type, null: false, default: 'weekly'

    add_index :users, :frequency
  end
end
