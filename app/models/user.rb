class User < ApplicationRecord
  # make email lower-case before saving to the db
  before_save {email.downcase!}
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
    length: { minimum: 6 }
end
