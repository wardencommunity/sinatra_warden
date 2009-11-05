Warden::Strategies.add(:password) do
  def valid?
    params['email'] && params['password']
  end

  def authenticate!
    u = User.authenticate(params['email'], params['password'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end
