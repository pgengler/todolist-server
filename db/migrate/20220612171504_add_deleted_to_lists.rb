class AddDeletedToLists < ActiveRecord::Migration[6.0]
  def change
    add_column :lists, :deleted, :boolean, default: false
  end
end
