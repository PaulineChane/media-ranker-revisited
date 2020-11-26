class User < ApplicationRecord
  has_many :works
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true
  validates :email, presence: true, uniqueness: true
  validates :uid, uniqueness: true, presence: true
  validates :provider, presence: true

  def self.build_from_provider(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = auth_hash[:provider]

    if auth_hash["info"]["name"].nil? # no name provided, get it from somewhere else
      user.username = auth_hash[:provider] == 'github' ? auth_hash["info"]["nickname"] : auth_hash["info"]["email"].split("@")[0]

      # name exists but because we can create some by email in another provider
      # we have to account that someone can now have the same username but two different
      # identities.
    else
      user.username = User.find_by_username(auth_hash["info"]["name"]).nil? ? auth_hash["info"]["name"] : "#{auth_hash["info"]["name"]}#{User.count}"
    end

    user.email = auth_hash["info"]["email"]

    # Note that the user has not been saved.
    # We'll choose to do the saving outside of this method
    return user
  end
end
