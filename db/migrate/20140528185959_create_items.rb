class CreateItems < ActiveRecord::Migration[4.1]
  def change
    create_table :items do |t|
      t.date :date
      t.string :event
      t.string :location
      t.time :start
      t.time :end
      t.boolean :done
      t.boolean :deleted

      t.timestamps
    end
  end
end
