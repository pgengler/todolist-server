class CreateRecurrenceRules < ActiveRecord::Migration[6.0]
  def change
    create_table :recurrence_rules do |t|
      t.string :description, null: false
      t.text :notes

      # Recurrence type: daily, weekdays, weekends, weekly, custom_weekly,
      # every_n_days, every_n_weeks, every_n_months, monthly_weekday, yearly, yearly_weekday
      t.string :recurrence_type, null: false

      # Interval for every_n_* patterns (default 1)
      t.integer :interval, default: 1

      # For weekly, every_n_weeks, monthly_weekday, yearly_weekday: day of week (0-6, Sunday=0)
      t.integer :day_of_week

      # For custom_weekly: array of days (e.g., [1,3,5] for Mon/Wed/Fri)
      t.integer :days_of_week, array: true, default: []

      # For every_n_months, yearly: day of month (1-31)
      t.integer :day_of_month

      # For monthly_weekday, yearly_weekday: which week (1-5, or -1 for last)
      t.integer :week_of_month

      # For yearly, yearly_weekday: month (1-12)
      t.integer :month

      # Reference date for interval calculations
      t.date :anchor_date

      # Optional constraints
      t.date :start_date
      t.date :end_date
      t.integer :max_instances

      # Track instance count
      t.integer :instances_created, default: 0

      t.timestamps
    end

    add_index :recurrence_rules, :recurrence_type
  end
end
