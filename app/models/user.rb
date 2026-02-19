class User < ApplicationRecord
  has_secure_password

  ROLES = { user: "user", admin: "admin" }.freeze

  validates :username,
            presence: true, uniqueness: true
  validates :email, presence: true,
            uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES.values }

  validates :password, presence: true,
            length: { minimum: 8 },
            if: :password_present_and_changed?
  validate  :password_requirements_are_met,
            if: :password_present_and_changed?

  # Role helper methods
  def user?
    role == "user"
  end

  def admin?
    role == "admin"
  end

  scope :admins, -> { where(role: "admin") }
  scope :regular_users, -> { where(role: "user") }

  private

  def password_present_and_changed?
    password.present? && (new_record? || will_save_change_to_password_digest?)
  end

  def password_requirements_are_met
    rules = {
      "must contain at least one lowercase letter" => /[a-z]+/,
      "must contain at least one uppercase letter" => /[A-Z]+/,
      "must contain at least one digit" => /\d+/,
      "must contain at least one special character" => /[^A-Za-z0-9]+/
    }

    rules.each do |message, regex|
      errors.add(:password, message) unless password.match(regex)
    end
  end
end
