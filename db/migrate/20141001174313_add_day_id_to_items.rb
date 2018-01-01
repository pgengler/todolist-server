class AddDayIdToItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :items, :day, index: true
  end
end
