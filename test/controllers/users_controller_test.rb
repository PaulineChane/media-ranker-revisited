require "test_helper"

describe UsersController do
  describe "create" do
    it "logs in an existing user" do
      start_count = User.count
      user = users(:dan)

      perform_login(user)
      must_redirect_to root_path
      expect(session[:user_id]).must_equal  user.id

      # Should *not* have created a new user
      expect(User.count).must_equal start_count
    end
  end
end
