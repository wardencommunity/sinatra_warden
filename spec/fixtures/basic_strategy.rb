


Warden::Strategies.add(:password) do
  def valid?
    # params['email'] && params['password']
    # p params
    true
  end

  def authenticate!
    u = User.authenticate(params['email'], params['password'])
    u.nil? ? fail!("Could not log you in.") : success!(u)
  end
end
