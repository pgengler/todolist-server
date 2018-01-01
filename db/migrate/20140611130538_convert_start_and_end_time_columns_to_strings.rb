class ConvertStartAndEndTimeColumnsToStrings < ActiveRecord::Migration[4.2]
  def change
    change_column :items, :start, :string
    change_column :items, :end, :string
  end
end
