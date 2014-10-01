class AddDayIdToItems < ActiveRecord::Migration
  def change
    add_reference :items, :day, index: true
  end
end
