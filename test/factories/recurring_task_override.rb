FactoryBot.define do
  factory :recurring_task_override do
    association :recurring_task_template
    original_date { Date.today }
    override_type { 'deleted' }
    override_data { {} }

    trait :deleted do
      override_type { 'deleted' }
      override_data { {} }
    end

    trait :modified do
      override_type { 'modified' }
      override_data { { 'description' => 'Modified task description' } }
    end

    trait :rescheduled do
      override_type { 'rescheduled' }
      override_data { { 'new_date' => (Date.today + 1.day).to_s } }
    end
  end
end
