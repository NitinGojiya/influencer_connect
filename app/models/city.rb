class City < ApplicationRecord
  has_many :profiles
  has_many :users, through: :profiles

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
