module UserPresenter

  class << self

    def single(user)
      {
        email: user.email,
        username: user.username,
        name: user.name,
        role: user.role
      }
    end

    def list(users)
      users.map do |user|
        single(user)
      end
    end
    
  end

end
