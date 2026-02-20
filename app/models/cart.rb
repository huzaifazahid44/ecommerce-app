class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  before_validation :ensure_token, on: :create

  validates :token, presence: true, uniqueness: true

  private

  def ensure_token
    self.token ||= SecureRandom.hex(10)
  end
end
