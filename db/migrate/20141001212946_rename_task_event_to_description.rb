class RenameTaskEventToDescription < ActiveRecord::Migration
	def change
		rename_column :tasks, :event, :description
	end
end
