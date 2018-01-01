class RenameItemsToTasks < ActiveRecord::Migration[4.2]
  def change
    rename_table :items, :tasks
  end
end
