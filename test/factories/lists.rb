FactoryBot.define do
  factory :list do
    name { 'A List' }
    list_type { 'list' }

    trait :day do
      list_type { 'day' }
      name { DateTime.now.strftime('%Y-%m-%d') }
    end

    trait :recurring_task_day do
      list_type { 'recurring-task-day' }
      name { DateTime.now.strftime('%A') }
    end
  end
end
