class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  # make email lower-case before saving to the db
  before_save :downcase_email

  before_create :create_activation_digest

  # validate presence and length of name
  validates :name, presence: true,
    length: { maximum: 50 }

  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
    length: { maximum: 255 },
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: { case_sensitive: false }

  # assert user has secure password
  has_secure_password

  # validates presence and length of password
  validates :password, presence: true,
    length: { minimum: 6 }, allow_nil: true

  ##################
  # public methods #
  ##################

  # returns the hash digest of the given string
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
        BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # forget user by setting remember_digest to nil 
  def forget
    update_attribute(:remember_digest, nil)
  end

  # activate the account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # send an activation email to the current user account
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  ###################
  # private methods #
  ###################
  private

  def downcase_email
    self.email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
