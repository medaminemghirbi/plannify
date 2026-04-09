require "test_helper"

class ClientProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get client_profiles_index_url
    assert_response :success
  end

  test "should get new" do
    get client_profiles_new_url
    assert_response :success
  end

  test "should get create" do
    get client_profiles_create_url
    assert_response :success
  end

  test "should get edit" do
    get client_profiles_edit_url
    assert_response :success
  end

  test "should get update" do
    get client_profiles_update_url
    assert_response :success
  end

  test "should get destroy" do
    get client_profiles_destroy_url
    assert_response :success
  end
end
