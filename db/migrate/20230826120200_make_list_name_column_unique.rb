class MakeListNameColumnUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :lists, [:name, :list_type], unique: true
  end
end
