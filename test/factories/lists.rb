FactoryBot.define do
  factory :list do
    name { 'A List' }
    list_type { 'list' }
  end

  trait :day do
    list_type { 'day' }
    name { DateTime.now.strftime('%Y-%m-%d') }
  end
end
