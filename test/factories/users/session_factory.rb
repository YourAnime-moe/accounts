FactoryBot.define do
  factory :users_session, class: 'Users::Session' do
    user
    token { SecureRandom.hex }
  end
end
