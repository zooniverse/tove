class User < ApplicationRecord
  validates :login, presence: true
end
