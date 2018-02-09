class AddSortOrderToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :sort_order, :integer, null: true
  end
end
