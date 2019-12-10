class User < ApplicationRecord
  attr_accessor :display_name, :admin, :roles
  validates :login, presence: true, uniqueness: true

  def self.from_jwt(data)
    id, login = data.values_at 'id', 'login'
    raise ArgumentError.new("Unable to parse JWT") if [id, login].include? nil

    User.where(id: id, login: login).first_or_create.tap do |user|
      user.display_name = data['dname']

      # Explicitly set user admin accessor if encoded in JWT
      user.admin = data['admin'] == true
    end
  end

  def roles
    @roles || { }
  end
end
