require "httparty"

class YoutubeChannelFetcherService
  BASE_URL = "https://www.googleapis.com/youtube/v3"

  SOCIAL_REGEX = %r{
    https?://(?:www\.)?
    (?:instagram\.com|
       facebook\.com|
       fb\.com|
       twitter\.com|
       x\.com|
       t\.me|
       linkedin\.com|
       threads\.net|
       youtube\.com|
       wa\.me|
       web\.whatsapp\.com|
       snapchat\.com|
       pinterest\.com|
       tiktok\.com)/
    [^\s]+
  }ix

  MIN_SUBSCRIBERS = 2000

  def initialize(keyword:, latitude: nil, longitude: nil, radius: nil)
    @keyword   = keyword
    @latitude  = latitude
    @longitude = longitude
    @radius    = radius
    @api_key   = ENV["YOUTUBE_KEY"]
  end

  def call
    channel_ids = fetch_channel_ids
    return [] if channel_ids.empty?

    channels = fetch_channel_details(channel_ids)

    results = []

    channels.each do |item|
      subs = item.dig("statistics", "subscriberCount").to_i
      next if subs < MIN_SUBSCRIBERS # 🚀 filter here

      channel_id   = item["id"]
      title        = item.dig("snippet", "title")
      description  = item.dig("snippet", "description").to_s
      about_bio    = item.dig("brandingSettings", "channel", "description").to_s
      profile_img  = item.dig("snippet", "thumbnails", "default", "url")

      combined_text = [ description, about_bio ].join(" ")

      links_array = item.dig("brandingSettings", "channel", "links") || []

      social_links = []
      social_links += combined_text.scan(SOCIAL_REGEX)
      social_links += links_array.map { |l| l["url"] }.compact.select { |url| url =~ SOCIAL_REGEX }
      social_links.uniq!

      channel_link =
        if item.dig("snippet", "customUrl").present?
          "https://www.youtube.com/#{item.dig("snippet", "customUrl")}"
        else
          "https://www.youtube.com/channel/#{channel_id}"
        end

      data = {
        channel_id: channel_id,
        channel_name: title,
        profile_image: profile_img,
        subscribers: subs,
        channel_link: channel_link,
        bio: about_bio.presence || description.presence,
        social_links: social_links.presence
      }

      puts "Channel & Social: #{data}" # 👉 Debugging output
      results << data
    end

    results
  end

  private

  def fetch_channel_ids
    search_url = "#{BASE_URL}/search"
    search_params = {
      part: "snippet",
      q: @keyword,
      type: "video",
      maxResults: 50,
      key: @api_key
    }

    if @latitude.present? && @longitude.present? && @radius.present?
      search_params[:location]       = "#{@latitude},#{@longitude}"
      search_params[:locationRadius] = @radius
    end

    response = HTTParty.get(search_url, query: search_params)
    puts "RAW SEARCH RESPONSE: #{response}" # 🔍 Debugging

    response["items"]&.map { |item| item.dig("snippet", "channelId") }&.uniq || []
  end

  def fetch_channel_details(channel_ids)
    return [] if channel_ids.empty?

    channels_url = "#{BASE_URL}/channels"
    channels_params = {
      part: "snippet,brandingSettings,statistics", # 👈 include statistics
      id: channel_ids.join(","),
      key: @api_key
    }

    response = HTTParty.get(channels_url, query: channels_params)
    response["items"] || []
  end
end
