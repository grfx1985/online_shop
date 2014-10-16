class AddDocColumnToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :doc, :string
  end
end
