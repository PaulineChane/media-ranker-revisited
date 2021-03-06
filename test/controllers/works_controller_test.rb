require "test_helper"

describe WorksController do
  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]
  let(:existing_work) { works(:album) }
  let( :dans_work) {works(:movie)}
  describe "logged out " do
    describe "root" do
      it "succeeds with all media types" do
        get root_path

        must_respond_with :success
      end

      it "succeeds with one media type absent" do
        only_book = works(:poodr)
        only_book.destroy

        get root_path

        must_respond_with :success
      end

      it "succeeds with no media" do
        Work.all do |work|
          work.destroy
        end

        get root_path

        must_respond_with :success
      end
    end

    describe "index" do
      it "blocks logged out users " do
        get works_path
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end
    describe "show" do
      it "blocks logged out users " do
        get work_path(works(:movie).id)
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end
    describe "new" do
      it "blocks logged out users " do
        get new_work_path(works(:movie).id)
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end
    describe "create" do
      it "blocks logged out users " do
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect{
          post works_path, params: new_work
        }.wont_change "Work.count"

        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end

    describe "edit" do
      it "blocks logged out users " do
        get edit_work_path(works(:movie).id)
        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end
    describe "update" do
      it "blocks logged out users " do
        updates = { work: { title: "edit title" } }

        expect {
          patch work_path(works(:movie)), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: works(:movie).id)

        expect(updated_work.title).wont_be_same_as "edit title"
        expect(flash[:result_text]).must_equal "You must log in to do that"
        must_redirect_to root_path
      end
    end
    describe "destroy" do
      it "blocks logged out users" do
        expect{
          delete work_path(works(:album))
        }.wont_change "Vote.count"

        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end

    describe "upvote" do
      it "redirects to the root if no user is logged in" do
        expect{
          post upvote_path(works(:album))
        }.wont_change "Vote.count"

        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to root_path
      end
    end
  end

  describe "logged in" do
    before do
      perform_login(users(:dan))
    end
    describe "index" do
      it "succeeds when there are works" do
        get works_path

        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all do |work|
          work.destroy
        end

        get works_path

        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        get new_work_path

        must_respond_with :success
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1

        new_work_id = Work.find_by(title: "Dirty Computer").id

        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        bad_work = { work: { title: nil, category: "book" } }

        expect {
          post works_path, params: bad_work
        }.wont_change "Work.count"

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          invalid_work = { work: { title: "Invalid Work", category: category } }

          expect { post works_path, params: invalid_work }.wont_change "Work.count"

          expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
          must_respond_with :bad_request
        end
      end
      describe "show" do
        it "succeeds for an extant work ID" do
          get work_path(existing_work.id)

          must_respond_with :success
        end

        it "renders 404 not_found for a bogus work ID" do
          destroyed_id = existing_work.id
          existing_work.destroy

          get work_path(destroyed_id)

          must_respond_with :not_found
        end
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID" do
        get edit_work_path(dans_work.id)

        must_respond_with :success
      end

      it "prevents user from editing work that they didn't add to database" do
        get edit_work_path(existing_work.id)

        expect(flash[:result_text]).must_equal "Forbidden access. You may be trying to modify a work you didn't add."

        must_redirect_to work_path(existing_work.id)
      end

      it "redirects to all works index for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        get edit_work_path(bogus_id)

        must_redirect_to works_path
      end
    end
    describe "update" do
      it "prevents user from updating work that they didnt create" do
        updates = { work: { title: "Dirty Computer" } }
        original_title = existing_work.title
        expect {
          put work_path(existing_work.id), params: updates
        }.wont_change "Work.count"
        not_updated_work = Work.find_by(id: existing_work.id)

        expect(not_updated_work.title).must_equal original_title
        expect(flash[:result_text]).must_equal "Forbidden access. You may be trying to modify a work you didn't add."

        # i'm editing this from the original tests : do these mean different things?
        # :success and :not_found tend have different statuses, i thought??
        must_respond_with :redirect
        must_redirect_to work_path(existing_work.id)
      end
      it "succeeds for valid data and an extant work ID belonging to the user" do
        updates = { work: { title: "Dirty Computer" } }

        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: dans_work.id)

        expect(updated_work.title).must_equal "Dirty Computer"
        must_respond_with :redirect
        must_redirect_to work_path(dans_work.id)
      end

      it "renders not_found if updates have invalid params" do
        updates = { work: { title: nil } }

        expect {
          put work_path(dans_work.id), params: updates
        }.wont_change "Work.count"

        work = Work.find_by(id: existing_work.id)

        must_respond_with :not_found
      end

      it "redirects to all works index for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        put work_path(bogus_id), params: { work: { title: "Test Title" } }

        must_redirect_to works_path
      end
    end
    describe "destroy" do
      it "succeeds for an extant work ID" do
        expect {
          delete work_path(dans_work.id)
        }.must_change "Work.count", -1

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        expect {
          delete work_path(bogus_id)
        }.wont_change "Work.count"

        expect(flash[:result_text]).must_equal "Work not found."

        must_redirect_to works_path
      end
    end
    describe "upvote" do
      it "redirects to the root page after the user has logged out" do
        expect(session[:user_id]).must_equal users(:dan).id

        delete logout_path params:{}

        expect{
          post upvote_path(works(:album))
        }.wont_change "Vote.count"

        assert_nil(session[:user_id])

        expect(flash[:result_text]).must_equal "You must log in to do that"
        must_redirect_to root_path
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        expect{
          post upvote_path(works(:movie)) # no vote for dan for this work in fixtures
        }.must_change "Vote.count", 1

        expect(flash[:result_text]).must_equal "Successfully upvoted!"
        # forgot to do this last time i wrote this test, oops
        must_redirect_to work_path(works(:movie))
      end

      it "redirects to the work page if the user has already voted for that work" do
        expect{
          post upvote_path(works(:album))
        }.wont_change "Vote.count", 1

        expect(flash[:result_text]).must_equal "Could not upvote"
        must_redirect_to work_path(works(:album))
      end
    end
  end
end
