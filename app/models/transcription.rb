class Transcription < ApplicationRecord
  belongs_to :workflow
  belongs_to :subject

  validates :subject_id, presence: true, uniqueness: true
  validates :status, presence: true
  validates :group_id, presence: true

  enum status: {
    unseen: 0,
    ready: 1,
    approved: 2,
    in_progress: 3
  }
end
