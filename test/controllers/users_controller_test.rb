require "test_helper"
# uhh... is this /too/ nested?
describe UsersController do
  describe "logged out " do
    describe "index" do
      it "blocks logged out users from access" do
        get users_path
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end

    describe "show" do
      it "blocks logged out users from access" do
        get user_path(users(:dan).id)
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "logs in an existing github user" do
        start_count = User.count
        user = users(:dan)

        perform_login(user)
        must_redirect_to root_path
        expect(session[:user_id]).must_equal  user.id

        # Should *not* have created a new user
        expect(User.count).must_equal start_count
      end

      it "logs in an existing google user" do
        start_count = User.count
        user = users(:google)

        perform_login(user)
        must_redirect_to root_path
        expect(session[:user_id]).must_equal  user.id

        # Should *not* have created a new user
        expect(User.count).must_equal start_count
      end

      it "creates a new github user" do
        user = User.new(provider: "github", uid: 99999, username: "new_user", email: "new@user.com")
        expect{
          perform_login(user)
        }.must_change "User.count", 1


        must_redirect_to root_path

        # The new user's ID should be set in the session
        expect(session[:user_id]).must_equal User.last.id
      end

      it "creates a new google user" do
        user = User.new(provider: "google_oauth2", uid: 91919, username: "new_user", email: "new@user.com")
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
      it "prevents logged out access to the route" do
        delete logout_path, params: {}

        assert_nil(session[:user_id])
        expect(flash[:result_text]).must_equal "You must log in to do that"
        must_redirect_to root_path
      end
    end
  end

  describe "logged in" do
    before do
      perform_login(users(:dan))
    end

    describe "index" do
      it "succeeds when there are users" do
        get users_path

        must_respond_with :success
      end

      # OBSOLETE - if a user can only view the index page logged in,
      # if someone is logged in then there is always one user at minimum.
      
      # it "succeeds when there are no users" do
      #   Vote.destroy_all
      #   User.destroy_all
      #
      #   get users_path
      #
      #   must_respond_with :success
      # end
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
    describe "destroy" do
      it "can logout an existing user" do
        # Arrange

        expect(session[:user_id]).must_equal users(:dan).id

        delete logout_path, params: {}

        assert_nil(session[:user_id])
        must_redirect_to root_path
      end
    end
  end
end
