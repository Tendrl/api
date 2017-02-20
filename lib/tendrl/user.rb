module Tendrl
  class User

    ADMIN = 'admin'
    NORMAL = 'normal'
    LIMITED = 'limited'

    ROLES = [ADMIN, NORMAL, LIMITED]

    attr_accessor :name, :email, :username, :role, :password_hash,
      :password_salt, :access_token

    def initialize(name, email, username, role)
      @name = name
      @email = email
      @username = username
      @role = role
      @password_hash = nil
      @password_salt = nil
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
        "/_tendrl/users/#{username}/access_token",
        value: token,
        ttl: 604800 # 1.week
      )
      token
    end

    def delete_token(token)
      Tendrl.etcd.delete("/_tendrl/users/#{username}/access_token")
    end

    class << self

      def all
        users = []
        Tendrl.etcd.get("/_tendrl/users", recursive: true).children.each do
          |child|
          attributes = {}
          child.children.each do |attribute|
            attributes[attribute.key.split('/')[-1].to_sym] = attribute.value
          end
          users << new(attributes[:name], attributes[:email],
                       attributes[:username], attributes[:role])
        end
        users
      end
      
      def find(username)
        attributes = {}
        Tendrl.etcd.get("/_tendrl/users/#{username}").
          children.each do |child|
          attributes[child.key.split('/')[-1].to_sym] = child.value
        end
        user = new(attributes[:name], attributes[:email], attributes[:username], attributes[:role])
        user.password_hash = attributes[:password_hash]
        user.password_salt = attributes[:password_salt]
        user.access_token = attributes[:access_token]
        user
      end

      def save(attributes)
        password = attributes.delete(:password)
        if password
          password_salt = BCrypt::Engine.generate_salt
          password_hash = BCrypt::Engine.hash_secret(
            password, password_salt
          )
          attributes.merge!(
            password_salt: password_salt,
            password_hash: password_hash
          )
        end
        Tendrl.etcd.set(
          "/_tendrl/users/#{attributes[:username]}",
          dir: true
        )

        attributes.each do |key, value|
          Tendrl.etcd.set("/_tendrl/users/#{attributes[:username]}/#{key}", value: value)
        end
        true
      end

      def authenticate(username, password)
        user = find(username)
        if user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
          user
        else
          nil
        end
      end

      def authenticate_access_token(username, access_token)
        user = find(username)
        if user.access_token == access_token
          user
        else
          nil
        end
      end

    end
  end
end
