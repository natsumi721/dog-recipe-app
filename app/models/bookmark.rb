class Bookmark < ApplicationRecord
    belongs_to :user
    belongs_to :recipe

    varidates :user_id, uniqueness: { scope: :recipe_id}
end
