require 'test_helper'

class EmailListsControllerTest < ActionController::TestCase
  test "should get generate" do
    get :generate
    assert_response :success
  end

end
