Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }
Warden::Manager.serialize_from_session{ |klass, id| klass.find(id) }

Warden::Strategies.add(:bcrypt_activerecord) do

  def valid?
    params["login"] || params["password"]
  end

  def authenticate!
    return fail! unless user = User.find(params["login"])

    if user.password == params["password"]
      success!(user)
    else
      errors.add(:login, "Login or Password incorrect")
      fail!
    end
  end

end
