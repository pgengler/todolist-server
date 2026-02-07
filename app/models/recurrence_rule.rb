class RecurrenceRule < ApplicationRecord
  RECURRENCE_TYPES = %w[
    daily
    weekdays
    weekends
    weekly
    custom_weekly
    every_n_days
    every_n_weeks
    every_n_months
    monthly_weekday
    yearly
    yearly_weekday
  ].freeze

  DAYS_OF_WEEK = (0..6).to_a.freeze
  WEEKS_OF_MONTH = [-1, 1, 2, 3, 4, 5].freeze
  MONTHS = (1..12).to_a.freeze

  has_many :tasks, dependent: :nullify

  validates :description, presence: true
  validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES }
  validates :interval, numericality: { greater_than: 0 }, allow_nil: true
  validates :day_of_week, inclusion: { in: DAYS_OF_WEEK }, allow_nil: true
  validates :day_of_month, inclusion: { in: 1..31 }, allow_nil: true
  validates :week_of_month, inclusion: { in: WEEKS_OF_MONTH }, allow_nil: true
  validates :month, inclusion: { in: MONTHS }, allow_nil: true

  validate :validate_required_fields_for_type
  validate :validate_days_of_week_array

  def applies_to?(date)
    return false if start_date && date < start_date
    return false if end_date && date > end_date
    return false if max_instances && instances_created >= max_instances

    case recurrence_type
    when 'daily'
      true
    when 'weekdays'
      (1..5).include?(date.wday)
    when 'weekends'
      [0, 6].include?(date.wday)
    when 'weekly'
      date.wday == day_of_week
    when 'custom_weekly'
      days_of_week.include?(date.wday)
    when 'every_n_days'
      matches_every_n_days?(date)
    when 'every_n_weeks'
      date.wday == day_of_week && matches_every_n_weeks?(date)
    when 'every_n_months'
      date.day == day_of_month && matches_every_n_months?(date)
    when 'monthly_weekday'
      matches_monthly_weekday?(date)
    when 'yearly'
      date.month == month && date.day == day_of_month
    when 'yearly_weekday'
      date.month == month && matches_monthly_weekday?(date)
    else
      false
    end
  end

  def instance_for(date, list)
    return nil unless applies_to?(date)

    existing = tasks.find_by(original_date: date)
    return existing if existing

    task = tasks.create!(
      description: description,
      notes: notes,
      list: list,
      original_date: date
    )
    increment!(:instances_created)
    task
  end

  def human_readable_schedule
    case recurrence_type
    when 'daily'
      'Every day'
    when 'weekdays'
      'Every weekday (Mon-Fri)'
    when 'weekends'
      'Every weekend (Sat-Sun)'
    when 'weekly'
      "Every #{day_name(day_of_week)}"
    when 'custom_weekly'
      "Every #{days_of_week.map { |d| day_name(d) }.join(', ')}"
    when 'every_n_days'
      interval == 1 ? 'Every day' : "Every #{interval} days"
    when 'every_n_weeks'
      base = interval == 1 ? 'Every week' : "Every #{interval} weeks"
      "#{base} on #{day_name(day_of_week)}"
    when 'every_n_months'
      base = interval == 1 ? 'Every month' : "Every #{interval} months"
      "#{base} on the #{ordinal(day_of_month)}"
    when 'monthly_weekday'
      "The #{week_ordinal(week_of_month)} #{day_name(day_of_week)} of every month"
    when 'yearly'
      "Every year on #{month_name(month)} #{ordinal(day_of_month)}"
    when 'yearly_weekday'
      "The #{week_ordinal(week_of_month)} #{day_name(day_of_week)} of #{month_name(month)} every year"
    else
      recurrence_type.humanize
    end
  end

  private

  def matches_every_n_days?(date)
    return true if interval == 1
    return false unless anchor_date

    days_diff = (date - anchor_date).to_i
    (days_diff % interval).zero?
  end

  def matches_every_n_weeks?(date)
    return true if interval == 1
    return false unless anchor_date

    weeks_diff = ((date - anchor_date).to_i / 7)
    (weeks_diff % interval).zero?
  end

  def matches_every_n_months?(date)
    return true if interval == 1
    return false unless anchor_date

    months_diff = (date.year * 12 + date.month) - (anchor_date.year * 12 + anchor_date.month)
    (months_diff % interval).zero?
  end

  def matches_monthly_weekday?(date)
    return false unless day_of_week && week_of_month
    return false unless date.wday == day_of_week

    if week_of_month == -1
      last_occurrence_of_weekday_in_month?(date)
    else
      nth_weekday_of_month(date) == week_of_month
    end
  end

  def nth_weekday_of_month(date)
    ((date.day - 1) / 7) + 1
  end

  def last_occurrence_of_weekday_in_month?(date)
    next_week = date + 7
    next_week.month != date.month
  end

  def validate_required_fields_for_type
    case recurrence_type
    when 'weekly', 'every_n_weeks'
      errors.add(:day_of_week, "is required for #{recurrence_type}") if day_of_week.nil?
    when 'custom_weekly'
      errors.add(:days_of_week, 'must have at least one day selected') if days_of_week.blank?
    when 'every_n_days', 'every_n_weeks', 'every_n_months'
      errors.add(:interval, "is required for #{recurrence_type}") if interval.nil?
      errors.add(:anchor_date, "is required for #{recurrence_type} when interval > 1") if interval && interval > 1 && anchor_date.nil?
    when 'every_n_months'
      errors.add(:day_of_month, 'is required for every_n_months') if day_of_month.nil?
    when 'monthly_weekday', 'yearly_weekday'
      errors.add(:day_of_week, "is required for #{recurrence_type}") if day_of_week.nil?
      errors.add(:week_of_month, "is required for #{recurrence_type}") if week_of_month.nil?
    when 'yearly'
      errors.add(:month, 'is required for yearly') if month.nil?
      errors.add(:day_of_month, 'is required for yearly') if day_of_month.nil?
    when 'yearly_weekday'
      errors.add(:month, 'is required for yearly_weekday') if month.nil?
    end
  end

  def validate_days_of_week_array
    return if days_of_week.blank?

    invalid_days = days_of_week.reject { |d| DAYS_OF_WEEK.include?(d) }
    if invalid_days.any?
      errors.add(:days_of_week, "contains invalid day values: #{invalid_days.join(', ')}")
    end
  end

  def day_name(day_num)
    Date::DAYNAMES[day_num]
  end

  def month_name(month_num)
    Date::MONTHNAMES[month_num]
  end

  def ordinal(num)
    return "#{num}th" if (11..13).include?(num % 100)

    case num % 10
    when 1 then "#{num}st"
    when 2 then "#{num}nd"
    when 3 then "#{num}rd"
    else "#{num}th"
    end
  end

  def week_ordinal(num)
    case num
    when -1 then 'last'
    when 1 then 'first'
    when 2 then 'second'
    when 3 then 'third'
    when 4 then 'fourth'
    when 5 then 'fifth'
    end
  end
end
