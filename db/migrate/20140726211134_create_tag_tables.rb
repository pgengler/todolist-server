class CreateTagTables < ActiveRecord::Migration
  def change
    create_table :tags do |t|
			t.string :name

			t.timestamps
		end

		create_table :items_tags, id: false do |t|
			t.references :item, null: false
			t.references :tag, null: false
		end

		add_index :items_tags, [:item_id, :tag_id], unique: true
  end
end
