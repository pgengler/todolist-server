class MakeTasksDoneColumnNonNullable < ActiveRecord::Migration[6.0]
  def up
    Task.where(done: nil).update_all(done: false)
    change_column_null :tasks, :done, false
    change_column_default :tasks, :done, false
  end

  def down
    change_column_null :tasks, :done, true
    change_column_default :tasks, :done, nil
  end
end
