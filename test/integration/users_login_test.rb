require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:zied)
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'

    post login_path, params: { session: { email: '', password: '' } }
    assert_template 'sessions/new'
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end

  test 'login with valid information followed by logout' do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }

    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    assert_select "a[href=?]", users_path

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path
    delete logout_path
    follow_redirect!
    assert_template 'static_pages/home'
    assert_not is_logged_in?
    assert_select 'a[href=?]', login_path, count: 1
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', user_path(@user), count: 0
    assert_select "a[href=?]", users_path, count: 0
  end

  test 'authenticate? should return false for a user with a nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_digest
  end

  test 'login without remembering' do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
