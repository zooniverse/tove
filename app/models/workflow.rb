class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true
end
