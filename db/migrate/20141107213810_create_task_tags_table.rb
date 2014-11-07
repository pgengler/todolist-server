class CreateTaskTagsTable < ActiveRecord::Migration
  def change
		create_join_table :tasks, :tags do |t|
			t.index :task_id
		end
  end
end
