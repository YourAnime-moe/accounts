# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Akinyele' }
    last_name  { 'Cafe-Febrissy' }
    email { 'support@misete.io' }
    username { 'akinyele' }
    password { 'test-password' }

    trait :blocked do
      blocked { true }
    end

    trait :active do
      active { true }
    end
  end
end
