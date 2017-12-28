FactoryBot.define do
  factory :day do
    date { DateTime.now.strftime('%Y-%m-%d') }
  end
end
