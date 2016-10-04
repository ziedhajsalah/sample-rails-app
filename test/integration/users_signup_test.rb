require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test 'invalid signup information' do
    get signup_path

    assert_select 'form[action="/signup"]'

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

  test 'valid signup information' do
    get signup_path

    assert_select 'form[action="/signup"]'

    assert_difference 'User.count' do
      post signup_path, params: { user: {
          name: 'zied',
          email: 'ziedhajsalah@gmail.com',
          password: 'secret',
          password_confirmation: 'secret'
      } }
    end

    follow_redirect!
    assert_template 'users/show'
    assert_select 'div.alert.alert-success'
    assert_not flash.blank?
  end
end
