class CreateTaskTagsTable < ActiveRecord::Migration[4.1]
  def change
    create_join_table :tasks, :tags do |t|
      t.index :task_id
    end
  end
end
