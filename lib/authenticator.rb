require 'jwt'
require 'openssl'

class Authenticator
  def self.key
    return @key if @key
    @key = OpenSSL::PKey.read File.read key_path
  end

  def self.from_token(token)
    decode(token)&.dig 0, 'data'
  end

  def self.decode(token)
    JWT.decode token, key, true, algorithm: 'RS512'
  rescue
    [{ }]
  end

  def self.key_path
    name = if Rails.env.production?
      'panoptes-jwt-production.pub'
    else
      'panoptes-jwt.pub'
    end

    Rails.root.join "config/credentials/#{ name }"
  end
end
