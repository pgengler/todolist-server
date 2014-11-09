namespace :todolist do
	desc "Import dump.json"
	task import: :environment do
		content = File.read('dump.json')
		data = JSON.parse(content)

		data.each do |record|
			next unless record['description']
			day = Day.find_or_create_by(date: record['date'])
			task = Task.create({
				description: record['description'],
				done: record['done'],
				day: day
			})
			record['tags'].each do |tag_name|
				tag = Tag.find_or_create_by(name: tag_name)
				task.tags << tag
			end
			task.save
		end
	end
end
