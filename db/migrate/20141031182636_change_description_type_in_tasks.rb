class ChangeDescriptionTypeInTasks < ActiveRecord::Migration[4.2]
  def change
    change_column :tasks, :description, :text
  end
end
