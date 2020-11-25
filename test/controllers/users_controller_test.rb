require "test_helper"

describe UsersController do

  describe "index" do
    it "succeeds when there are users" do
      get users_path

      must_respond_with :success
    end

    it "succeeds when there are no works" do
      Vote.destroy_all
      User.destroy_all

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an extant user ID" do
      get user_path(users(:dan).id)

      must_respond_with :success
    end

    it "renders 404 not_found for a bogus work ID" do

      get work_path(-1)

      must_respond_with :not_found
    end
  end
  
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

    it "creates a new user" do
      user = User.new(provider: "github", uid: 99999, username: "new_user", email: "new@user.com")
      expect{
        perform_login(user)
      }.must_change "User.count", 1


      must_redirect_to root_path

      # The new user's ID should be set in the session
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
      # no username -> invalid
      user = User.new(provider: 'github',  uid: nil, username: nil, email: 'no@uid.com')

      expect{
        perform_login(user)
      }.wont_change User.count

      must_redirect_to root_path

      user = User.find_by(uid: user.uid, provider: user.provider)
      assert_nil(user)

      # check session
      assert_nil(session[:user_id])
    end
  end


  describe "destroy" do
    before do
      perform_login(users(:dan))
    end
    it "can logout an existing user" do
      # Arrange

      expect(session[:user_id]).must_equal users(:dan).id

      delete logout_path, params: {}

      assert_nil(session[:user_id])
      must_redirect_to root_path
    end

    it "guest users on that route" do
      # we'll put this in in later waves
    end
  end
end
