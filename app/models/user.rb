class User < ApplicationRecord
  has_many :works
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :uid, uniqueness: true, presence: true
  validates :provider, presence: true

  def self.build_from_provider(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid].to_s
    user.provider = auth_hash[:provider]

    if auth_hash["info"]["name"].nil?
      user.username = auth_hash[:provider] == 'github' ? auth_hash["info"]["nickname"] : auth_hash["info"]["email"].split("@")[0]
    else
      user.username = auth_hash["info"]["name"]
    end

    user.email = auth_hash["info"]["email"]

    # Note that the user has not been saved.
    # We'll choose to do the saving outside of this method
    return user
  end
end
