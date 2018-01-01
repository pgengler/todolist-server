class CreateDays < ActiveRecord::Migration[4.1]
  def change
    create_table :days do |t|
      t.date :date

      t.timestamps
    end
  end
end
