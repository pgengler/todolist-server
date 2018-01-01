class CreateTags < ActiveRecord::Migration[4.1]
  def change
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
