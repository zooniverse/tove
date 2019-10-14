class User < ApplicationRecord
  attr_accessor :display_name, :admin, :roles
  validates :login, presence: true
end
