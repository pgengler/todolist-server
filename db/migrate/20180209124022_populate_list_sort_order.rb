class PopulateListSortOrder < ActiveRecord::Migration[5.1]
  def up
    Date::DAYNAMES.each_with_index do |day, index|
      list = List.find_by!(name: day, list_type: 'recurring-task-day')
      list.sort_order = index
      list.save!
    end

    List.where(list_type: 'list').each_with_index do |list, index|
      list.sort_order = index
      list.save!
    end
  end

  def down
    List.update_all(sort_order: nil)
  end
end
