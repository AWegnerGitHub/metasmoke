require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test 'should get index' do
    sign_in users(:admin_user)
    get :index
    assert_response :success
  end

  test 'should require admin privileges to view page' do
    [:ignored_users, :flagged].each do |path|
      sign_out :user

      assert_raises ActionController::RoutingError do
        get path
      end

      sign_in users(:approved_user)
      assert_raises ActionController::RoutingError do
        get path
      end
    end
  end

  test 'should get invalidated page' do
    sign_in users(:admin_user)

    get :recently_invalidated
    assert_response :success
  end

  test 'should get user feedback page' do
    sign_in users(:admin_user)

    get :user_feedback, params: { user_id: users(:approved_user).id }
    assert_response :success
    assert assigns(:feedback)
    assert assigns(:feedback_count)
    assert assigns(:invalid_count)
  end

  test 'should get users page' do
    sign_in users(:admin_user)
    get :users
    assert_response :success
  end
end
