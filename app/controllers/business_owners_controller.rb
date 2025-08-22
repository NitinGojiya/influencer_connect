class BusinessOwnersController < ApplicationController
  require 'ostruct'

  def index
    @user = Current.session.user

    influencers_data = [
  {
    "photo_url": "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=687&auto=format&fit=crop",
    "name": "Alice Johnson",
    "bio": "Travel enthusiast and food blogger.",
    "ig_link": "https://instagram.com/alicejohnson",
    "youtube_link": "https://youtube.com/alicevlogs",
    "twitter_link": "https://twitter.com/alicejohnson",
    "content_quality": 9,
    "language": "English",
    "category": "Travel",
    "mobile": true,
    "mobile_number": "+12345678901",
    "city": "Ahmedabad"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=687&auto=format&fit=crop",
    "name": "Brian Smith",
    "bio": "Tech reviewer and gadget guru.",
    "ig_link": "https://instagram.com/briansmith",
    "youtube_link": "https://youtube.com/techwithbrian",
    "twitter_link": "https://twitter.com/briansmith",
    "content_quality": 8,
    "language": "English",
    "category": "Tech",
    "mobile": false,
    "mobile_number": "+19876543210",
    "city": "Rajkot"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1598970434795-0c54fe7c0642?q=80&w=687&auto=format&fit=crop",
    "name": "Clara Lee",
    "bio": "Fitness coach and lifestyle influencer.",
    "ig_link": "https://instagram.com/claralee",
    "youtube_link": "https://youtube.com/clarafit",
    "twitter_link": "https://twitter.com/claralee",
    "content_quality": 9,
    "language": "English",
    "category": "Fitness",
    "mobile": true,
    "mobile_number": "+11234567890",
    "city": "Jamnagar"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=687&auto=format&fit=crop",
    "name": "Sophia Brown",
    "bio": "Fashion model and style inspiration.",
    "ig_link": "https://instagram.com/sophiabrown",
    "youtube_link": "https://youtube.com/sophiabstyle",
    "twitter_link": "https://twitter.com/sophiabrown",
    "content_quality": 9,
    "language": "English",
    "category": "Fashion",
    "mobile": true,
    "mobile_number": "+19873456789",
    "city": "Ahmedabad"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=80&w=687&auto=format&fit=crop",
    "name": "Raj Patel",
    "bio": "Food vlogger exploring street food culture.",
    "ig_link": "https://instagram.com/rajpatel",
    "youtube_link": "https://youtube.com/rajfoodie",
    "twitter_link": "https://twitter.com/rajpatel",
    "content_quality": 8,
    "language": "Gujarati",
    "category": "Food",
    "mobile": true,
    "mobile_number": "+919876543210",
    "city": "Rajkot"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1525182008055-f88b95ff7980?q=80&w=687&auto=format&fit=crop",
    "name": "Emily Davis",
    "bio": "Lifestyle influencer sharing daily routines and positivity.",
    "ig_link": "https://instagram.com/emilydavis",
    "youtube_link": "https://youtube.com/emilylifestyle",
    "twitter_link": "https://twitter.com/emilydavis",
    "content_quality": 9,
    "language": "English",
    "category": "Lifestyle",
    "mobile": false,
    "mobile_number": "+14443332222",
    "city": "Jamnagar"
  },
  {
    "photo_url": "https://images.unsplash.com/photo-1581090700227-4c4a3d1a3b58?q=80&w=687&auto=format&fit=crop",
    "name": "Kevin Wright",
    "bio": "Gamer and streamer bringing esports content.",
    "ig_link": "https://instagram.com/kevinwright",
    "youtube_link": "https://youtube.com/kevplays",
    "twitter_link": "https://twitter.com/kevinwright",
    "content_quality": 10,
    "language": "English",
    "category": "Gaming",
    "mobile": true,
    "mobile_number": "+17778889999",
    "city": "Ahmedabad"
  }
]


    # Convert to OpenStructs
    @influencers = influencers_data.map { |hash| OpenStruct.new(hash) }

    # --- 🔍 Apply Filters ---
    if params[:q].present?
      query = params[:q].downcase
      @influencers = @influencers.select do |inf|
        inf.name.downcase.include?(query) || inf.bio.downcase.include?(query)
      end
    end

    if params[:type].present? && params[:type] != "Influencer Type"
      @influencers = @influencers.select { |inf| inf.category == params[:type] }
    end

    if params[:city].present? && params[:city] != "Select City"
      @influencers = @influencers.select { |inf| inf.city == params[:city] }
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
