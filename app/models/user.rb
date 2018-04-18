module Tendrl
  class User

    ADMIN = 'admin'
    NORMAL = 'normal'
    LIMITED = 'limited'

    ROLES = [ADMIN, NORMAL, LIMITED]

    attr_accessor :name, :email, :username, :role, :password_hash,
      :password_salt, :email_notifications

    def initialize(attributes={})
      attributes = attributes.with_indifferent_access
      @name = attributes[:name]
      @email = attributes[:email]
      @username = attributes[:username]
      @email_notifications = attributes[:email_notifications]
      @role = attributes[:role]
      @password_hash = attributes[:password_hash]
      @password_salt = attributes[:password_salt]
    end

    def attributes
      {
        name: name,
        email: email,
        username: username,
        email_notifications: email_notifications,
        role: role
      }
    end

    def admin?
      @role == ADMIN
    end

    def normal?
      admin? || @role == NORMAL
    end

    def limited?
      @role == LIMITED
    end

    def generate_token
      token = SecureRandom.hex(32)
      Tendrl.etcd.set(
        "/_tendrl/access_tokens/#{token}",
        value: username,
        ttl: 604800 # 1.week
      )
      token
    end

    def delete_token(access_token)
      Tendrl.etcd.delete("/_tendrl/access_tokens/#{access_token}")
    end

    def new_record?
      password_hash.blank?
    end

    def delete
      Tendrl.etcd.delete("/_tendrl/indexes/notifications/email_notifications/#{username}") rescue Etcd::KeyNotFound
      Tendrl.etcd.cached_delete("/_tendrl/users/#{username}", recursive: true)
    end

    class << self
      def all
        Tendrl.etcd.get('/_tendrl/users', recursive: true)
              .children.collect_concat do |user|
          new(Tendrl.recurse(user).values.first)
        end
      end

      def find(username)
        attrs = Tendrl.recurse(
          Tendrl.etcd.cached_get("/_tendrl/users/#{username}")
        )[username]
        user = new(attrs)
        user
      rescue Etcd::KeyNotFound
        nil
      end

      def find_user_by_access_token(token)
        username = Tendrl.etcd.cached_get("/_tendrl/access_tokens/#{token}").value
        find(username)
      rescue Etcd::KeyNotFound
        nil
      end

      def save(attributes)
        user_path = "/_tendrl/users/#{attributes[:username]}"
        Tendrl.etcd.cache.delete user_path
        Tendrl.etcd.set "#{user_path}/data", value: attributes.to_json
        user = find(attributes[:username])
        post_save_hooks(user)
        user
      end

      def post_save_hooks(user)
        update_email_notification_indexes(user)
      end

      def update_email_notification_indexes(user)
        email_index = "/_tendrl/indexes/notifications/email_notifications/#{user.username}"
        if user.email_notifications
          Tendrl.etcd.set(email_index, value: user.email)
        else
          Tendrl.etcd.delete(email_index) rescue Etcd::KeyNotFound
        end
      end

      def authenticate(username, password)
        user = find(username)
        if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
          user
        else
          nil
        end
      end

      def authenticate_access_token(access_token)
        if user = find_user_by_access_token(access_token)
          user
        else
          nil
        end
      rescue Etcd::KeyNotFound
        nil
      end

    end
  end
end
