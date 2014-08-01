class ItemTag < ActiveRecord::Base
	belongs_to :item
	belongs_to :tag

	validates :position, presence: true
	validates :position, uniqueness: { scope: :tag_id }
end