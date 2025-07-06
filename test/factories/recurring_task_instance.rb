FactoryBot.define do
  factory :recurring_task_instance do
    association :recurring_task_template
    scheduled_date { Date.today }
    status { 'pending' }
    task { nil }

    trait :created do
      status { 'created' }
      association :task
    end

    trait :skipped do
      status { 'skipped' }
    end

    trait :deleted do
      status { 'deleted' }
    end
  end
end
