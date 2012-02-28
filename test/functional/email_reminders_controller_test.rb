#require 'test_helper'
#
#class EmailRemindersControllerTest < ActionController::TestCase
#  setup do
#    @email_reminder = email_reminders(:one)
#  end
#
#  test "should get index" do
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:email_reminders)
#  end
#
#  test "should get new" do
#    get :new
#    assert_response :success
#  end
#
#  test "should create email_reminder" do
#    assert_difference('EmailReminder.count') do
#      post :create, email_reminder: @email_reminder.attributes
#    end
#
#    assert_redirected_to email_reminder_path(assigns(:email_reminder))
#  end
#
#  test "should show email_reminder" do
#    get :show, id: @email_reminder.to_param
#    assert_response :success
#  end
#
#  test "should get edit" do
#    get :edit, id: @email_reminder.to_param
#    assert_response :success
#  end
#
#  test "should update email_reminder" do
#    put :update, id: @email_reminder.to_param, email_reminder: @email_reminder.attributes
#    assert_redirected_to email_reminder_path(assigns(:email_reminder))
#  end
#
#  test "should destroy email_reminder" do
#    assert_difference('EmailReminder.count', -1) do
#      delete :destroy, id: @email_reminder.to_param
#    end
#
#    assert_redirected_to email_reminders_path
#  end
#end
