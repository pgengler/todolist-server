class RecurringTaskTemplate < ApplicationRecord
  belongs_to :user
  has_many :recurring_task_instances, dependent: :destroy
  has_many :recurring_task_overrides, dependent: :destroy

  validates :description, presence: true
  validates :recurrence_rule, presence: true
  validates :start_date, presence: true
  validate :valid_recurrence_rule

  scope :active, -> { where(active: true) }

  def occurs_on?(date)
    return false if date < start_date
    return false if end_date && date > end_date
    return false if has_override_for?(date, 'deleted')

    case recurrence_rule['type']
    when 'weekly'
      occurs_weekly_on?(date)
    when 'monthly'
      occurs_monthly_on?(date)
    else
      false
    end
  end

  def has_override_for?(date, override_type = nil)
    query = recurring_task_overrides.where(original_date: date)
    query = query.where(override_type: override_type) if override_type
    query.exists?
  end

  def description_for_date(date)
    override = recurring_task_overrides.find_by(original_date: date, override_type: 'modified')
    if override && override.override_data['description']
      override.override_data['description']
    else
      description
    end
  end

  private

  def valid_recurrence_rule
    return if recurrence_rule.blank?

    case recurrence_rule['type']
    when 'weekly'
      validate_weekly_rule
    when 'monthly'
      validate_monthly_rule
    else
      errors.add(:recurrence_rule, 'must have a valid type (weekly or monthly)')
    end
  end

  def validate_weekly_rule
    unless recurrence_rule['interval'].is_a?(Integer) && recurrence_rule['interval'] > 0
      errors.add(:recurrence_rule, 'weekly rule must have a positive interval')
    end

    unless recurrence_rule['days_of_week'].is_a?(Array) && recurrence_rule['days_of_week'].present?
      errors.add(:recurrence_rule, 'weekly rule must specify days_of_week')
      return
    end

    valid_days = %w[sunday monday tuesday wednesday thursday friday saturday]
    invalid_days = recurrence_rule['days_of_week'] - valid_days
    if invalid_days.any?
      errors.add(:recurrence_rule, "contains invalid days: #{invalid_days.join(', ')}")
    end
  end

  def validate_monthly_rule
    unless recurrence_rule['interval'].is_a?(Integer) && recurrence_rule['interval'] > 0
      errors.add(:recurrence_rule, 'monthly rule must have a positive interval')
    end

    has_day_of_month = recurrence_rule['day_of_month'].present?
    has_week_of_month = recurrence_rule['week_of_month'].present? && recurrence_rule['day_of_week'].present?

    unless has_day_of_month || has_week_of_month
      errors.add(:recurrence_rule, 'monthly rule must specify either day_of_month or week_of_month with day_of_week')
    end

    if has_day_of_month && has_week_of_month
      errors.add(:recurrence_rule, 'monthly rule cannot specify both day_of_month and week_of_month')
    end

    if has_day_of_month && !(1..31).include?(recurrence_rule['day_of_month'])
      errors.add(:recurrence_rule, 'day_of_month must be between 1 and 31')
    end

    if has_week_of_month
      valid_weeks = %w[first second third fourth last]
      unless valid_weeks.include?(recurrence_rule['week_of_month'])
        errors.add(:recurrence_rule, "week_of_month must be one of: #{valid_weeks.join(', ')}")
      end

      valid_days = %w[sunday monday tuesday wednesday thursday friday saturday]
      unless valid_days.include?(recurrence_rule['day_of_week'])
        errors.add(:recurrence_rule, 'day_of_week must be a valid day name')
      end
    end
  end

  def occurs_weekly_on?(date)
    weeks_since_start = ((date - start_date) / 7).to_i
    return false unless (weeks_since_start % recurrence_rule['interval']).zero?

    day_name = date.strftime('%A').downcase
    recurrence_rule['days_of_week'].include?(day_name)
  end

  def occurs_monthly_on?(date)
    months_since_start = (date.year * 12 + date.month) - 
                        (start_date.year * 12 + start_date.month)
    return false unless (months_since_start % recurrence_rule['interval']).zero?

    if recurrence_rule['day_of_month']
      date.day == recurrence_rule['day_of_month']
    elsif recurrence_rule['week_of_month']
      matches_week_and_day_of_month?(date)
    else
      false
    end
  end

  def matches_week_and_day_of_month?(date)
    return false unless date.strftime('%A').downcase == recurrence_rule['day_of_week']

    case recurrence_rule['week_of_month']
    when 'first'
      date.day <= 7
    when 'second'
      date.day.between?(8, 14)
    when 'third'
      date.day.between?(15, 21)
    when 'fourth'
      date.day.between?(22, 28)
    when 'last'
      # Check if this is the last occurrence of this weekday in the month
      next_week = date + 7.days
      date.month != next_week.month
    else
      false
    end
  end
end
