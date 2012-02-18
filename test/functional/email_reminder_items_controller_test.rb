require 'test_helper'

class EmailReminderItemsControllerTest < ActionController::TestCase
  setup do
    @email_reminder_item = email_reminder_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:email_reminder_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create email_reminder_item" do
    assert_difference('EmailReminderItem.count') do
      post :create, email_reminder_item: @email_reminder_item.attributes
    end

    assert_redirected_to email_reminder_item_path(assigns(:email_reminder_item))
  end

  test "should show email_reminder_item" do
    get :show, id: @email_reminder_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @email_reminder_item.to_param
    assert_response :success
  end

  test "should update email_reminder_item" do
    put :update, id: @email_reminder_item.to_param, email_reminder_item: @email_reminder_item.attributes
    assert_redirected_to email_reminder_item_path(assigns(:email_reminder_item))
  end

  test "should destroy email_reminder_item" do
    assert_difference('EmailReminderItem.count', -1) do
      delete :destroy, id: @email_reminder_item.to_param
    end

    assert_redirected_to email_reminder_items_path
  end
end
