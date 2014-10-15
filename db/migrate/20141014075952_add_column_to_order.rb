class AddColumnToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :extra, :text
  end
end
