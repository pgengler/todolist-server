namespace :recurring_tasks do
  desc "Migrate v2 recurring tasks to v3 recurring task templates"
  task migrate_v2_to_v3: :environment do
    puts "Starting migration of v2 recurring tasks to v3..."
    
    migrated_count = 0
    error_count = 0
    
    # Get all users who have tasks in recurring-task-day lists
    user_ids = Task.joins(:list)
                   .where(lists: { list_type: 'recurring-task-day' })
                   .pluck('DISTINCT tasks.user_id')
    
    user_ids.each do |user_id|
      user = User.find(user_id)
      puts "\nMigrating recurring tasks for user #{user.email}..."
      
      # Get all recurring-task-day lists with tasks
      List.where(list_type: 'recurring-task-day').each do |list|
        day_name = list.name.downcase
        
        # Get unique task descriptions for this day
        task_descriptions = list.tasks.where(user_id: user_id).pluck('DISTINCT description')
        
        task_descriptions.each do |description|
          begin
            # Create v3 recurring task template
            template = user.recurring_task_templates.create!(
              description: description,
              start_date: Date.today,
              recurrence_rule: {
                type: 'weekly',
                interval: 1,
                days_of_week: [day_name]
              },
              active: true
            )
            
            puts "  ✓ Migrated: '#{description}' for #{day_name}"
            migrated_count += 1
          rescue => e
            puts "  ✗ Error migrating '#{description}': #{e.message}"
            error_count += 1
          end
        end
      end
    end
    
    puts "\n" + "="*50
    puts "Migration complete!"
    puts "Successfully migrated: #{migrated_count} recurring tasks"
    puts "Errors: #{error_count}" if error_count > 0
    puts "="*50
  end
  
  desc "Dry run of v2 to v3 migration (no changes made)"
  task migrate_v2_to_v3_dry_run: :environment do
    puts "DRY RUN: Analyzing v2 recurring tasks..."
    
    total_count = 0
    
    # Get all users who have tasks in recurring-task-day lists
    user_ids = Task.joins(:list)
                   .where(lists: { list_type: 'recurring-task-day' })
                   .pluck('DISTINCT tasks.user_id')
    
    user_ids.each do |user_id|
      user = User.find(user_id)
      puts "\nUser: #{user.email}"
      
      List.where(list_type: 'recurring-task-day').each do |list|
        task_descriptions = list.tasks.where(user_id: user_id).pluck('DISTINCT description')
        
        if task_descriptions.any?
          puts "  #{list.name}:"
          task_descriptions.each do |description|
            puts "    - #{description}"
            total_count += 1
          end
        end
      end
    end
    
    puts "\n" + "="*50
    puts "Total recurring tasks that would be migrated: #{total_count}"
    puts "="*50
  end
end
