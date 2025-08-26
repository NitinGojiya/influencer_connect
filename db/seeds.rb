require 'faker'
require 'open-uri'

# Create Business Owner
business_owner = User.find_or_create_by!(email_address: "business@gmail.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end
business_owner.add_role :business_owner

# Create Influencers
20.times do |i|
  user = User.find_or_create_by!(email_address: "influencer#{i + 1}@gmail.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  user.add_role(:influencer) unless user.has_role?(:influencer)

  # Generate a random city using Faker
  city_name = Faker::Address.city
  city = City.find_or_create_by!(name: city_name)

  # Assign profile attributes
  profile = user.profile || user.build_profile
  profile.assign_attributes(
    full_name: Faker::Name.name,
    nickname: Faker::Internet.username(specifier: nil, separators: %w[_]),
    gender: %w[male female other].sample,
    country: Faker::Address.country,
    dist: city.name,
    language: Faker::Nation.language,
    content_type: %w[Fashion Tech Food Gaming Travel Lifestyle].sample,
    city: city,
    bio: Faker::Lorem.paragraph(sentence_count: 2),
    mobile: Faker::PhoneNumber.cell_phone_in_e164
  )

  # Attach profile picture if not already attached
  unless profile.profile_pic.attached?
    begin
      file = URI.open("https://i.pravatar.cc/300?img=#{rand(1..70)}")
      profile.profile_pic.attach(io: file, filename: "avatar#{i + 1}.jpg")
    rescue OpenURI::HTTPError, SocketError => e
      Rails.logger.warn "Skipping avatar for influencer#{i + 1}: #{e.message}"
    end
  end

  profile.save!

  # Create Social Platform for this profile if not already present
  unless profile.social_platform.present?
    profile.create_social_platform!(
      ig_id: Faker::Internet.username(specifier: 5..10),
      ig_link: "https://instagram.com/#{Faker::Internet.username}",
      ig_followers: rand(1_000..100_000),
      youtube_id: Faker::Alphanumeric.alphanumeric(number: 8),
      youtube_link: "https://youtube.com/channel/#{Faker::Alphanumeric.alphanumeric(number: 12)}",
      youtube_subscriber: rand(500..50_000),
      twitter_id: Faker::Internet.username(specifier: 5..10),
      twitter_link: "https://twitter.com/#{Faker::Internet.username}",
      twitter_followers: rand(1_000..50_000)
    )
  end
end
