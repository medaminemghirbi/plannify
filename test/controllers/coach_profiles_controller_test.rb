require "test_helper"

class CoachProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coach_profiles_index_url
    assert_response :success
  end

  test "should get new" do
    get coach_profiles_new_url
    assert_response :success
  end

  test "should get create" do
    get coach_profiles_create_url
    assert_response :success
  end

  test "should get edit" do
    get coach_profiles_edit_url
    assert_response :success
  end

  test "should get update" do
    get coach_profiles_update_url
    assert_response :success
  end

  test "should get destroy" do
    get coach_profiles_destroy_url
    assert_response :success
  end
end
