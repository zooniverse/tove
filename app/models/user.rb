class User < ApplicationRecord
  attr_accessor :display_name, :admin, :roles
  validates :login, presence: true, uniqueness: true

  def roles
    @roles || { }
  end
end
