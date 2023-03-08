class AddNotesToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :notes, :text
  end
end
