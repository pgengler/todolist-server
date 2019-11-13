FactoryBot.define do
  factory :task do
    description { 'a thing to do' }
    done { false }
    list
  end
end
