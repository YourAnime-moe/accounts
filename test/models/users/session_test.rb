require "test_helper"

class Users::SessionTest < ActiveSupport::TestCase
  test 'generates a unique token' do
    rand_token = SecureRandom.hex
    user = FactoryBot.create(:user)

    SecureRandom.stubs(:hex).returns(rand_token)
    
    session = Users::Session.create(expires_on: 1.day.from_now, user: user)
    assert session.valid?

    invalid_session = Users::Session.create(expires_on: 1.day.from_now, user: user)
    assert !invalid_session.valid?
  end
end
