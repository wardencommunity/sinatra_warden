require 'dm-core'
require 'bcrypt'

Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }

Warden::Strategies.add(:bcrypt_datamapper) do
  def valid?
    params["email"] || params["password"]
  end

  def authenticate!
    return fail!("Could not log in") unless user = User.first(:email => params["email"])
    user.password == params["password"] ? success!(user) : fail!("Could not log in")
  end
end
