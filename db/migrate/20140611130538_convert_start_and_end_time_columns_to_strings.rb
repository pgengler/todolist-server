class ConvertStartAndEndTimeColumnsToStrings < ActiveRecord::Migration
    def change
        change_column :items, :start, :string
        change_column :items, :end, :string
    end
end
