require 'bcrypt'

class User
    include DataMapper::Resource

    property :id, Serial

    property :first_name,       String, length: 20, format: ::FU::DB::Property::NAMEREGEX, allow_nil: true
    property :last_name,        String, length: 20, format: ::FU::DB::Property::NAMEREGEX, allow_nil: true

    property :email,            String, length: 50, unique: true
    property :username,         String, length: 50, allow_nil: true, unique: true
    property :password,         String, length: 255

    # Find user based on the three different login methods (email, username, mobile_username)
    def self.locate(account)
        return User.find_by_email(account) || User.find_by_username(account) || User.find_by_mobile_username(account)
    end

    # Check given password against what's in the database.  We currently
    # authenticate in three scenarios, two of which use the same password field.
    # Unfortunately, mobile_password is currently stored in the clear...
    def valid_password?(password)
        return ::BCrypt::Password.new(self.password.sub(/\A\$2y/, '$2a')).is_password?(password)

    end

    def password=(password)
        hashed_password = ::BCrypt::Password.create(password)
        attribute_set(:password, hashed_password)
    end

end
