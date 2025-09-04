class SocialPlatform < ApplicationRecord
    belongs_to :profile
    has_paper_trail
end
