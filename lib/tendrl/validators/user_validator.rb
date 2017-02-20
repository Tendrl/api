module Tendrl
  module Validator
    class UserValidator
      include ActiveModel::Validations

      attr_accessor :name, :username, :email, :password,
        :password_confirmation, :role

      validates :name, :username, presence: true, length: { maximum: 100 }

      validates :password, confirmation: true, length: 8..20, if:
        :password_required?

      validates :password_confirmation, presence: true, if: :password_required?

      validates :email, format: { 
        with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      }

      validates :role, inclusion: { in: Tendrl::User::ROLES }

      validate :uniqueness

      def initialize(action, params)
        @action = action
        @name = params[:name]
        @username = params[:username]
        @password = params[:password]
        @password_confirmation = params[:password_confirmation]
        @email = params[:email]
        @role = params[:role]
      end

      def attributes
        {
          name: @name,
          username: @username,
          password: @password,
          email: @email
        }
      end

      private

      def create?
        @action == :create
      end

      def update?
        @action == :update
      end

      def password_required?
        if create?
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

          if usernames.include?(@username)
            errors.add(:username, 'is taken')
          end

          if emails.include?(@email)
            errors.add(:email, 'is taken')
          end
        end
      end

    end
  end
end

