class YoutubeConnectsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  GOOGLE_CLIENT_ID = ENV["GOOGLE_CLIENT_ID"]
  GOOGLE_CLIENT_SECRET = ENV["GOOGLE_CLIENT_SECRET"]
  REDIRECT_URI = "#{ENV["HOST_URL"]}youtube_connects/callback"
  SCOPE = "https://www.googleapis.com/auth/youtube.readonly"

  # Step 1: Redirect to Google OAuth
  def connect
    oauth_url = "https://accounts.google.com/o/oauth2/auth?" +
                "client_id=#{GOOGLE_CLIENT_ID}" +
                "&redirect_uri=#{REDIRECT_URI}" +
                "&scope=#{SCOPE}" +
                "&response_type=code" +
                "&access_type=offline" +  # gets refresh token
                "&prompt=consent"

    redirect_to oauth_url, allow_other_host: true
  end

  # Step 2: Handle callback, exchange code for access token
  def callback
    code = params[:code]
    token_url = URI("https://oauth2.googleapis.com/token")

    response = Net::HTTP.post_form(token_url, {
      code: code,
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: "authorization_code"
    })

    data = JSON.parse(response.body)

    if data["access_token"].present?
      session[:youtube_access_token] = data["access_token"]
      redirect_to youtube_connects_profile_path
    else
      render json: { error: "Failed to get access token", details: data }, status: :unauthorized
    end
  end

  # Step 3: Fetch YouTube channel and save to DB
  def profile
    access_token = session[:youtube_access_token]

    if access_token.blank?
      return render json: { error: "No YouTube access token found. Connect first." }, status: :unauthorized
    end

    # Fetch channel data
    url = URI("https://www.googleapis.com/youtube/v3/channels?part=id,snippet,statistics&mine=true&access_token=#{access_token}")
    response = Net::HTTP.get_response(url)
    channel_data = JSON.parse(response.body)

    if channel_data["error"].present? || channel_data["items"].blank?
      return render json: { error: "Failed to fetch YouTube channel", details: channel_data }, status: :bad_request
    end

    channel = channel_data["items"].first

    # Store in SocialPlatform
    profile = Current.session.user.profile
    social_platform = profile.social_platform || profile.build_social_platform

    social_platform.update!(
      youtube_id: channel["id"],
      youtube_link: "https://www.youtube.com/channel/#{channel['id']}",
      youtube_subscriber: channel.dig("statistics", "subscriberCount").to_s
    )

    # Redirect to influencer profile
    redirect_to influencer_profile_path, notice: "YouTube connected successfully!"
  end
end
