class RenameItemsToTasks < ActiveRecord::Migration
	def change
		rename_table :items, :tasks
	end
end
