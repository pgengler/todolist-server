class ItemTag < ActiveRecord::Base
	belongs_to :item
	belongs_to :tag

	validates :position, uniqueness: { scope: :tag_id }

	before_save :set_position

	private

	def set_position
		return if self.position
		last_item_tag = ItemTag.where(item_id: item.id, tag_id: tag.id).order('position desc').first
		if last_item_tag
			self.position = last_item_tag.position + 1
		else
			self.position = 1
		end
	end
end