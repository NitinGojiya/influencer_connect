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
                URI.encode_www_form(
                  client_id: GOOGLE_CLIENT_ID,
                  redirect_uri: REDIRECT_URI,
                  scope: SCOPE,
                  response_type: "code",
                  access_type: "offline",
                  prompt: "consent"
                )

    redirect_to oauth_url, allow_other_host: true
  end

  # Step 2: Handle callback, exchange code for access token
  def callback
    code = params[:code]
    token_data = exchange_code_for_token(code)

    if token_data["access_token"].present?
      session[:youtube_access_token] = token_data["access_token"]
      redirect_to youtube_connects_profile_path
    else
      redirect_to root_path, alert: t("alerts.youtube_connects.access_token_failed")
    end
  end

  # Step 3: Fetch YouTube channel and save to DB
  def profile
    access_token = session[:youtube_access_token]
    return redirect_to root_path, alert: t("alerts.youtube_connects.no_token") if access_token.blank?

    channel_data = fetch_youtube_channel(access_token)

    if channel_data["error"].present? || channel_data["items"].blank?
      return redirect_to root_path, alert: t("alerts.youtube_connects.fetch_failed")
    end

    channel = channel_data["items"].first
    profile = Current.session.user.profile
    social_platform = profile.social_platform || profile.build_social_platform

    social_platform.update!(
      youtube_id: channel["id"],
      youtube_link: "https://www.youtube.com/channel/#{channel['id']}",
      youtube_subscriber: channel.dig("statistics", "subscriberCount").to_s
    )

    redirect_to influencer_profile_path, notice: t("alerts.youtube_connects.success")
  end

  private

  def exchange_code_for_token(code)
    uri = URI("https://oauth2.googleapis.com/token")
    response = Net::HTTP.post_form(uri, {
      code: code,
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: "authorization_code"
    })
    JSON.parse(response.body)
  end

  def fetch_youtube_channel(access_token)
    uri = URI("https://www.googleapis.com/youtube/v3/channels?part=id,snippet,statistics&mine=true&access_token=#{access_token}")
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
