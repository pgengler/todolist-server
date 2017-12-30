class MigrateDaysToLists < ActiveRecord::Migration[5.0]
  def up
    Day.where('date is not null').all.each do |day|
      list = List.create!(name: day.date, list_type: :day)
      day.tasks.update_all(list_id: list.id)
    end
  end

  def down
    List.delete_all
  end
end
