class MetaConnectsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  APP_ID = ENV["META_APP_ID"]
  APP_SECRET = ENV["META_APP_SECRET"]
  REDIRECT_URI = "#{ENV["HOST_URL"]}meta_connects/callback"
    # REDIRECT_URI = "https://8cdc865a8b16.ngrok-free.app/meta_connects/callback"

  # Step 1: Redirect user to Meta OAuth
  def connect
    oauth_url = "https://www.facebook.com/v21.0/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{REDIRECT_URI}&scope=instagram_basic,pages_show_list,instagram_manage_insights"
    redirect_to oauth_url, allow_other_host: true
  end

  # Step 2: Handle callback, exchange code for access token
  def callback
    code = params[:code]

    token_url = URI("https://graph.facebook.com/v21.0/oauth/access_token")
    token_url.query = URI.encode_www_form({
      client_id: APP_ID,
      client_secret: APP_SECRET,
      redirect_uri: REDIRECT_URI,
      code: code
    })

    response = Net::HTTP.get_response(token_url)
    data = JSON.parse(response.body)

    if data["access_token"]
      session[:access_token] = data["access_token"]
      redirect_to meta_connects_profile_path
    else
      render json: { error: "Failed to get access token", details: data }, status: :unauthorized
    end
  end

  # Step 3: Fetch Instagram Profile
  def profile
  access_token = session[:access_token]
  Rails.logger.info ">>> ACCESS TOKEN in Rails session: #{access_token}"

  if access_token.blank?
    return render json: { error: "No access token found. Please connect again." }, status: :unauthorized
  end

  # 1. Get user’s Facebook Pages
  pages_url = URI("https://graph.facebook.com/v21.0/me/accounts?access_token=#{access_token}")
  pages_response = Net::HTTP.get_response(pages_url)
  pages_data = JSON.parse(pages_response.body)

  if pages_data["error"].present?
    return render json: { error: "Failed to fetch Facebook pages", details: pages_data }, status: :bad_request
  end

  if pages_data["data"].blank?
    return render json: { error: "No Facebook pages found or insufficient permissions", details: pages_data }, status: :not_found
  end

  # Pick the first page (or extend to let user choose)
  page_id = pages_data["data"].first["id"]

  # 2. Get Instagram Business Account ID
  page_url = URI("https://graph.facebook.com/v21.0/#{page_id}?fields=instagram_business_account&access_token=#{access_token}")
  page_response = Net::HTTP.get_response(page_url)
  page_data = JSON.parse(page_response.body)

  if page_data["error"].present?
    return render json: { error: "Failed to fetch page details", details: page_data }, status: :bad_request
  end

  ig_user_id = page_data.dig("instagram_business_account", "id")
  if ig_user_id.blank?
    return render json: { error: "No Instagram account linked to this Facebook page", details: page_data }, status: :not_found
  end

  # 3. Fetch Instagram profile
  ig_url = URI("https://graph.facebook.com/v21.0/#{ig_user_id}?fields=id,username,profile_picture_url,followers_count&access_token=#{access_token}")
  ig_response = Net::HTTP.get_response(ig_url)
  ig_data = JSON.parse(ig_response.body)

  if ig_data["error"].present?
    return render json: { error: "Failed to fetch Instagram profile", details: ig_data }, status: :bad_request
  end

  # 4. Store IG data in DB
  profile = Current.session.user.profile
  social_platform = profile.social_platform || profile.build_social_platform

  social_platform.update!(
    ig_id: ig_data["id"],
    ig_link: "https://instagram.com/#{ig_data['username']}",
    ig_followers: ig_data["followers_count"].to_s
  )

  # 5. Redirect to influencer profile page
  redirect_to influencer_profile_path, notice: "Instagram account connected successfully!"
end

end
