class ChangeDescriptionTypeInTasks < ActiveRecord::Migration[4.1]
  def change
    change_column :tasks, :description, :text
  end
end
