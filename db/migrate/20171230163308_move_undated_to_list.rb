class MoveUndatedToList < ActiveRecord::Migration[5.0]
  def up
    undated_day = Day.find_by(date: nil)
    return unless undated_day
    list = List.create!(name: 'Other', list_type: 'list')
    undated_day.tasks.update_all(list_id: list.id)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
