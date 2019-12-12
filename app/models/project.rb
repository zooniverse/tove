class Project < ApplicationRecord
  has_many :workflows, dependent: :destroy

  validates :slug, presence: true
end
