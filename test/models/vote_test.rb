require "test_helper"

describe Vote do
  describe "relations" do
    it "has a user" do
      v = votes(:one)
      expect(v).must_respond_to :user
      expect(v.user).must_be_kind_of User
    end

    it "has a work" do
      v = votes(:one)
      expect(v).must_respond_to :work
      expect(v.work).must_be_kind_of Work
    end
  end

  describe "validations" do
    let (:user1) { User.new(provider: "google_oauth2", uid: "090909090909", username: "chris", email: "chris@chris.com") }
    let (:user2) {  User.new(provider: "google_oauth2", uid: "090909090903", username: "luda", email: "luda@chris.com")  }
    let (:work1) { users(:dan).works.new(category: "book", title: "House of Leaves") }
    let (:work2) { users(:dan).works.new(category: "book", title: "For Whom the Bell Tolls") }

    it "allows one user to vote for multiple works" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work2)
      expect(vote2.valid?).must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user2, work: work1)
      expect(vote2.valid?).must_equal true
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: user1, work: work1)
      vote1.save!
      vote2 = Vote.new(user: user1, work: work1)
      expect(vote2.valid?).must_equal false
      expect(vote2.errors.messages).must_include :user
    end
  end
end
