class AddDeliveryTimeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_time, :datetime
  end
end
