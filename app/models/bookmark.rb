class Bookmark < ApplicationRecord
    belongs_to :user
    belongs_to :recipe
    belongs_to :dog

    validates :user_id, uniqueness: { scope: [:recipe_id, :dog_id] }
end
