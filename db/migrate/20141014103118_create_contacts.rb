class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :title
      t.text :description
      t.string :email

      t.timestamps
    end
  end
end
