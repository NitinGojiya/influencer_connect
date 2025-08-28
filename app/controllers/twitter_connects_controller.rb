class TwitterConnectsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"
  require "base64"
  require "securerandom"

  CLIENT_ID = ENV["TWITTER_CLIENT_ID"]
  CLIENT_SECRET = ENV["TWITTER_CLIENT_SECRET"]
  REDIRECT_URI = "#{ENV["HOST_URL"]}twitter_connects/callback"

  # Step 1: Redirect user to Twitter OAuth2
  def connect
    # Generate PKCE code_verifier and code_challenge
    code_verifier = SecureRandom.hex(32) # long random string
    session[:twitter_code_verifier] = code_verifier

    oauth_url = "https://twitter.com/i/oauth2/authorize?" +
      {
        response_type: "code",
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "tweet.read users.read follows.read offline.access",
        state: SecureRandom.hex(10),
        code_challenge: code_verifier,       # 🔑 PKCE uses same string if method=plain
        code_challenge_method: "plain"
      }.to_query

    redirect_to oauth_url, allow_other_host: true
  end

  # Step 2: Handle callback
  def callback
    code = params[:code]
    code_verifier = session[:twitter_code_verifier] # ✅ now set in connect

    uri = URI("https://api.twitter.com/2/oauth2/token")

    req = Net::HTTP::Post.new(uri)
    req.set_form_data({
      code: code,
      grant_type: "authorization_code",
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      code_verifier: code_verifier
    })

    # Twitter requires Basic Auth header
    credentials = Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")
    req["Authorization"] = "Basic #{credentials}"
    req["Content-Type"] = "application/x-www-form-urlencoded"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    data = JSON.parse(res.body)

    if data["access_token"]
      session[:twitter_access_token] = data["access_token"]
      session[:twitter_refresh_token] = data["refresh_token"] # if offline.access was requested
      redirect_to profile_twitter_connects_path
    else
      render json: { error: "Failed to get access token", details: data }
    end
  end

  # Step 3: Fetch Twitter profile (same as your code)
  def profile
    access_token = session[:twitter_access_token]
    return render json: { error: "No access token found. Please connect again." } if access_token.blank?

    uri = URI("https://api.twitter.com/2/users/me?user.fields=profile_image_url,public_metrics")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{access_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    data = JSON.parse(res.body)

    if data["errors"].present?
      render json: { error: "Failed to fetch Twitter profile", details: data }
    else
      twitter_user = data["data"]

      profile = Current.session.user.profile
      social = profile.social_platform || profile.build_social_platform

      social.twitter_id = twitter_user["id"]
      social.twitter_link = "https://twitter.com/#{twitter_user["username"]}"
      social.twitter_followers = twitter_user["public_metrics"]["followers_count"]
      social.save!

      redirect_to influencer_profile_path, notice: "Twitter connected successfully!"
    end
  end
end
