require "test_helper"

class DogsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get dogs_new_url
    assert_response :success
  end

  test "should get creat" do
    get dogs_creat_url
    assert_response :success
  end
end
