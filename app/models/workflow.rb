class Workflow < ApplicationRecord
  belongs_to :project
  has_many :subjects
  has_many :transcriptions

  validates :display_name, presence: true

  def groups
    transcriptions.group(:group_id).count
  end
end
