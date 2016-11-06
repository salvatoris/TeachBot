require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "we cannot create user without necessary data" do
    # invalid
    user = User.new(username: '', email: 'rodion2014@inbox.ru', password_digest: 'password')
    assert_not user.save

    # invalid
    user = User.new(username: 'Rodion', email: '', password_digest: 'password')
    assert_not user.save

    # invalid
    user = User.new(username: 'Rodion', email: 'rodion2014@inbox.ru', password_digest: '')
    assert_not user.save

    # valid
    user = User.new(username: 'Rodion', email: 'rodion2014@inbox.ru', password_digest: 'password')
    assert user.save
  end

  test "authenticated? should return false for a user with nil digest" do
    @user = User.new(username: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    assert_not @user.authenticated?(:activation, '')
  end

end
