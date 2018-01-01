class RenameTaskEventToDescription < ActiveRecord::Migration[4.1]
  def change
    rename_column :tasks, :event, :description
  end
end
