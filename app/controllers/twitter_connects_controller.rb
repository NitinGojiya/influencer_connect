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
    code_verifier = SecureRandom.hex(32)
    session[:twitter_code_verifier] = code_verifier

    oauth_url = "https://twitter.com/i/oauth2/authorize?" +
      {
        response_type: "code",
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        scope: "tweet.read users.read follows.read offline.access",
        state: SecureRandom.hex(10),
        code_challenge: code_verifier,
        code_challenge_method: "plain"
      }.to_query

    redirect_to oauth_url, allow_other_host: true
  end

  # Step 2: Handle callback
  def callback
    code = params[:code]
    code_verifier = session[:twitter_code_verifier]

    response = exchange_code_for_token(code, code_verifier)
    data = JSON.parse(response.body)

    if data["access_token"].present?
      session[:twitter_access_token] = data["access_token"]
      session[:twitter_refresh_token] = data["refresh_token"]
      redirect_to profile_twitter_connects_path
    else
      redirect_to root_path, alert: t("alerts.twitter_connects.access_token_failed")
    end
  end

  # Step 3: Fetch Twitter profile
  def profile
    access_token = session[:twitter_access_token]
    return redirect_to root_path, alert: t("alerts.twitter_connects.no_token") if access_token.blank?

    data = fetch_profile(access_token)

    if data["errors"].present?
      redirect_to root_path, alert: t("alerts.twitter_connects.profile_failed")
    else
      twitter_user = data["data"]

      profile = Current.session.user.profile
      social = profile.social_platform || profile.build_social_platform

      social.update!(
        twitter_id: twitter_user["id"],
        twitter_link: "https://twitter.com/#{twitter_user["username"]}",
        twitter_followers: twitter_user["public_metrics"]["followers_count"]
      )

      redirect_to influencer_profile_path, notice: t("alerts.twitter_connects.success")
    end
  end

  private

  def exchange_code_for_token(code, code_verifier)
    uri = URI("https://api.twitter.com/2/oauth2/token")
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(
      code: code,
      grant_type: "authorization_code",
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      code_verifier: code_verifier
    )
    credentials = Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")
    req["Authorization"] = "Basic #{credentials}"
    req["Content-Type"] = "application/x-www-form-urlencoded"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
  end

  def fetch_profile(access_token)
    uri = URI("https://api.twitter.com/2/users/me?user.fields=profile_image_url,public_metrics")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{access_token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(res.body)
  end
end
