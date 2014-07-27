# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


tag_one = Tag.create!(name: 'a tag')
tag_two = Tag.create!(name: 'another tag')

item_one = Item.create!(event: 'Item with one tag')
item_two = Item.create!(event: 'Item with two tags')

item_one.tags << tag_one

item_two.tags << tag_one
item_two.tags << tag_two

item_one.save
item_two.save