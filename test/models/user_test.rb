require "test_helper"

describe User do
  describe "relations" do
    it "has many works" do
      pauline = users(:pauline)
      expect(pauline).must_respond_to :works
      pauline.works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end

    it "has a list of votes" do
      dan = users(:dan)
      expect(dan).must_respond_to :votes
      dan.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      dan = users(:dan)
      expect(dan).must_respond_to :ranked_works
      dan.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end


  end

  describe "validations" do
    it "requires a username, uid, provider, and email" do
      user = User.new
      expect(user.valid?).must_equal false

      [:username, :email, :uid, :provider].each do |field|
        expect(user.errors.messages).must_include field
      end

    end

    it "requires a unique username, email, uid" do
      # we have users in the fixtures
      # we'll use me! pauline!
      user2 = User.new(provider: 'github', username: "pauline", uid: 23456, email: "pauline@site.com" )
      result = user2.save
      expect(result).must_equal false

      [:username, :uid, :email].each do |field|
        expect(user2.errors.messages).must_include field
      end
    end
  end

  describe "build_from_provider" do
    before do
      @auth_hash = { provider: "github",
                     uid: 13371337,
                     "info"=> { "name" => "test",
                                "nickname" => "nickname",
                                "email" => "test@test.com"
                          }
                    }
    end
    it "builds a hash using github name when present" do
      new_user = User.build_from_provider(@auth_hash)

      expect(new_user.valid?).must_equal true

      expect(new_user.provider).must_equal @auth_hash[:provider]
      expect(new_user.uid).must_equal @auth_hash[:uid]
      expect(new_user.username).must_equal @auth_hash["info"]["name"]
      expect(new_user.email).must_equal @auth_hash["info"]["email"]
    end
    it "builds a hash using github nickname when name not present" do
      @auth_hash["info"]["name"] = nil
      new_user = User.build_from_provider(@auth_hash)

      expect(new_user.valid?).must_equal true

      expect(new_user.provider).must_equal @auth_hash[:provider]
      expect(new_user.uid).must_equal @auth_hash[:uid]
      expect(new_user.username).must_equal @auth_hash["info"]["nickname"]
      expect(new_user.email).must_equal @auth_hash["info"]["email"]
    end
  end
end
