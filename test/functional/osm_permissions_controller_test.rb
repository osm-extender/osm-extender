require 'test_helper'

class OsmPermissionsControllerTest < ActionController::TestCase
  test "should get view" do
    get :view
    assert_response :success
  end

end
