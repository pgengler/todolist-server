class RenameTaskEventToDescription < ActiveRecord::Migration[4.2]
  def change
    rename_column :tasks, :event, :description
  end
end
