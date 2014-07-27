class Item < ActiveRecord::Base
	has_many :item_tags
	has_many :tags, through: :item_tags
end
