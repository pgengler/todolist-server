class ConvertStartAndEndTimeColumnsToStrings < ActiveRecord::Migration[4.1]
    def change
        change_column :items, :start, :string
        change_column :items, :end, :string
    end
end
