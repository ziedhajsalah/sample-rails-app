require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path

    assert_select 'form[action="/users"]'

    assert_no_difference 'User.count' do
      post signup_path, params: { user: {
          name: '',
          email: 'user@invalid',
          password: 'foo',
          password_confirmation: 'bar'
      } }
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation>ul>li'
    assert_select 'div.alert.alert-danger'
  end

  test 'valid signup information with account activation' do
    get signup_path

    assert_select 'form[action="/users"]'

    assert_difference 'User.count', 1 do
      post users_path, params: { user: {
          name: 'zied',
          email: 'ziedhajsalah@example.com',
          password: 'secret',
          password_confirmation: 'secret'
      } }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # try to login before activation
    log_in_as user
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path('invalid_token', email: user.email)
    assert_not is_logged_in?
    # valid token wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated? 

    follow_redirect!
    assert is_logged_in?
    assert_template 'users/show'
    assert_select 'div.alert.alert-success'
    assert_not flash.blank?
  end
end
