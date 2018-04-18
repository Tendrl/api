module UserPresenter
  class << self
    def single(user)
      {
        email: user.email,
        username: user.username,
        name: user.name,
        role: user.role,
        email_notifications: user.email_notifications
      }
    end

    def list(users)
      users.map do |user|
        single(user)
      end
    end
  end
end
