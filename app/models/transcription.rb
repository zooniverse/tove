class Transcription < ApplicationRecord
  belongs_to :workflow

  validates :status, presence: true
  validates :group_id, presence: true
  validates :text, length: { minimum: 0, allow_nil: false, message: "can't be nil" }

  enum status: {
    unseen: 0,
    ready: 1,
    approved: 2,
    in_progress: 3
  }
end
