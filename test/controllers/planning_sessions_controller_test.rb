require "test_helper"

class PlanningSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get planning_sessions_index_url
    assert_response :success
  end

  test "should get new" do
    get planning_sessions_new_url
    assert_response :success
  end

  test "should get create" do
    get planning_sessions_create_url
    assert_response :success
  end

  test "should get edit" do
    get planning_sessions_edit_url
    assert_response :success
  end

  test "should get update" do
    get planning_sessions_update_url
    assert_response :success
  end

  test "should get destroy" do
    get planning_sessions_destroy_url
    assert_response :success
  end
end
