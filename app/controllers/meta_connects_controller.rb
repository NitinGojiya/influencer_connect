class MetaConnectsController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  APP_ID = ENV["META_APP_ID"]
  APP_SECRET = ENV["META_APP_SECRET"]
  REDIRECT_URI = "#{ENV["HOST_URL"]}meta_connects/callback"

  def connect
    oauth_url = "https://www.facebook.com/v21.0/dialog/oauth?" +
      URI.encode_www_form(
        client_id: APP_ID,
        redirect_uri: REDIRECT_URI,
        scope: "instagram_basic,pages_show_list,instagram_manage_insights"
      )

    redirect_to oauth_url, allow_other_host: true
  end

  def callback
    response = exchange_code_for_token(params[:code])
    data = JSON.parse(response.body)

    if data["access_token"].present?
      session[:access_token] = data["access_token"]
      redirect_to meta_connects_profile_path
    else
      redirect_to root_path, alert: t("alerts.meta_connects.access_token_failed")
    end
  end

  def profile
    access_token = session[:access_token]
    return redirect_to root_path, alert: t("alerts.meta_connects.no_token") if access_token.blank?

    pages_data = fetch_json("me/accounts", access_token)
    return redirect_to root_path, alert: t("alerts.meta_connects.pages_failed") if pages_data["error"].present?
    return redirect_to root_path, alert: t("alerts.meta_connects.no_pages") if pages_data["data"].blank?

    page_id = pages_data["data"].first["id"]
    page_data = fetch_json("#{page_id}?fields=instagram_business_account", access_token)

    return redirect_to root_path, alert: t("alerts.meta_connects.page_details_failed") if page_data["error"].present?

    ig_user_id = page_data.dig("instagram_business_account", "id")
    return redirect_to root_path, alert: t("alerts.meta_connects.no_instagram") if ig_user_id.blank?

    ig_data = fetch_json("#{ig_user_id}?fields=id,username,profile_picture_url,followers_count", access_token)
    return redirect_to root_path, alert: t("alerts.meta_connects.ig_profile_failed") if ig_data["error"].present?

    # Store IG data in DB
    profile = Current.session.user.profile
    social_platform = profile.social_platform || profile.build_social_platform
    social_platform.update!(
      ig_id: ig_data["id"],
      ig_link: "https://instagram.com/#{ig_data['username']}",
      ig_followers: ig_data["followers_count"].to_s
    )

    redirect_to influencer_profile_path, notice: t("alerts.meta_connects.success")
  end

  private

  def exchange_code_for_token(code)
    token_url = URI("https://graph.facebook.com/v21.0/oauth/access_token")
    token_url.query = URI.encode_www_form(
      client_id: APP_ID,
      client_secret: APP_SECRET,
      redirect_uri: REDIRECT_URI,
      code: code
    )
    Net::HTTP.get_response(token_url)
  end

  def fetch_json(path, access_token)
    url = URI("https://graph.facebook.com/v21.0/#{path}&access_token=#{access_token}")
    response = Net::HTTP.get_response(url)
    JSON.parse(response.body)
  end
end
