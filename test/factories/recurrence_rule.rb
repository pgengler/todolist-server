FactoryBot.define do
  factory :recurrence_rule do
    description { 'Test recurring task' }
    recurrence_type { 'weekly' }
    day_of_week { 1 }
    start_date { Date.today }

    trait :daily do
      recurrence_type { 'daily' }
      day_of_week { nil }
    end

    trait :weekdays do
      recurrence_type { 'weekdays' }
      day_of_week { nil }
    end

    trait :monthly do
      recurrence_type { 'every_n_months' }
      interval { 1 }
      day_of_month { 15 }
    end
  end
end
