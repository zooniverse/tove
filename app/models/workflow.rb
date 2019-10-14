class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects

  validates :display_name, presence: true
end
