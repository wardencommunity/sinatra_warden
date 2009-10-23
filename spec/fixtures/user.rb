require 'dm-core'
require 'bcrypt'

class User
  include DataMapper::Resource

  property :id, Serial
  property :email, String
  property :encrypted_password, String

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    attribute_set(encrypted_password, @password)
  end

  def password
    @password ||= BCrypt::Password.new(encrypted_password)
  end

end
