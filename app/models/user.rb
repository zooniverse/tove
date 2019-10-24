class User < ApplicationRecord
  attr_accessor :display_name, :admin, :roles
  validates :login, presence: true

  def self.from_jwt(data = { })
    id, login = data&.values_at 'id', 'login'
    return unless id && login

    User.where(id: id, login: login).first_or_create do |user|
      user.display_name = data['dname']
      user.admin = data['admin'] == true # explicit
    end
  end

  def roles
    @roles || { }
  end
end
