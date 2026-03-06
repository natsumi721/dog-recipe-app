class User < ApplicationRecord
  authenticates_with_sorcery!
    has_secure_password
    has_many :dogs, dependent: :destroy
end
