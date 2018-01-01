class RenameItemsToTasks < ActiveRecord::Migration[4.1]
	def change
		rename_table :items, :tasks
	end
end
