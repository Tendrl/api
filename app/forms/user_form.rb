module Tendrl
  class UserForm
    include ActiveModel::Validations

    attr_accessor :name, :username, :email, :password,
      :role, :email_notifications

    validates :name, :username, presence: true, length: { minimum: 4, maximum: 20 }

    validates :password, length: { minimum: 8 }, if: :password_required?

    validates :email, format: {
      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    }

    validates :email_notifications, inclusion: { in: [true, false, "true", "false"] }

    validates :role, inclusion: { in: Tendrl::User::ROLES }

    validate :uniqueness

    def initialize(user, params)
      @user = user
      @name = params[:name] || user.name
      @username = params[:username] || user.username
      @email = params[:email] || user.email
      @role = params[:role] || user.role
      @password = params.delete(:password)
      if @password
        @password_salt = BCrypt::Engine.generate_salt
        @password_hash = BCrypt::Engine.hash_secret(
          @password, @password_salt
        )
      else
        @password_salt = user.password_salt
        @password_hash = user.password_hash
      end
      @email_notifications = if params[:email_notifications].nil?
                               user.email_notifications
                             else
                               [true, 'true'].include? params[:email_notifications]
                             end
    end

    def attributes
      {
        name: @name,
        username: @username,
        password_salt: @password_salt,
        password_hash: @password_hash,
        email: @email,
        role: @role,
        email_notifications: @email_notifications
      }
    end

    private

    def password_required?
      if @user.new_record?
        true
      else
        password.present?
      end
    end

    def uniqueness
      if @username.present? || @email.present?
        users = Tendrl::User.all
        usernames, emails = [], []
        users.each do |user|
          usernames << user.username
          emails << user.email
        end

        if usernames.include?(@username) && @username != @user.username
          errors.add(:username, 'is taken')
        end

        if emails.include?(@email) && @email != @user.email
          errors.add(:email, 'is taken')
        end
      end
    end

  end
end

