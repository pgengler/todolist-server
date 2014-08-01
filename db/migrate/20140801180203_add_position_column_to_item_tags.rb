class AddPositionColumnToItemTags < ActiveRecord::Migration
  def change
    add_column :item_tags, :position, :integer
  end
end
