require "csv"
media_file = Rails.root.join("db", "media_seeds.csv")
# hosts the existing database with a default valid user that is essentially owned by the site itself
default_user = User.create!(provider: 'github',
                            uid: "000000000000000000000",
                            username: "MediaRankerDatabase",
                            email: "database@mediaranker.com")

CSV.foreach(media_file, headers: true, header_converters: :symbol, converters: :all) do |row|
  data = Hash[row.headers.zip(row.fields)]
  puts data
  default_user.works.create!(data)
end
