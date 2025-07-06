FactoryBot.define do
  factory :recurring_task_template do
    association :user
    description { "Recurring task" }
    start_date { Date.today }
    end_date { nil }
    active { true }
    
    recurrence_rule do
      {
        type: 'weekly',
        interval: 1,
        days_of_week: ['monday']
      }
    end

    trait :weekly do
      recurrence_rule do
        {
          type: 'weekly',
          interval: 1,
          days_of_week: ['monday', 'wednesday', 'friday']
        }
      end
    end

    trait :bi_weekly do
      recurrence_rule do
        {
          type: 'weekly',
          interval: 2,
          days_of_week: ['friday']
        }
      end
    end

    trait :monthly_date do
      recurrence_rule do
        {
          type: 'monthly',
          interval: 1,
          day_of_month: 15
        }
      end
    end

    trait :monthly_relative do
      recurrence_rule do
        {
          type: 'monthly',
          interval: 1,
          week_of_month: 'third',
          day_of_week: 'thursday'
        }
      end
    end

    trait :inactive do
      active { false }
    end
  end
end
