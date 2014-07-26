class RemoveUnusedColumnsFromItems < ActiveRecord::Migration
  def change
		remove_column :items, :location
		remove_column :items, :start
		remove_column :items, :end
  end
end
