require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it "同じ犬・同じレシピの重複はできない" do
    user = create(:user)
    dog = create(:dog, user: user)
    recipe = create(:recipe)

    create(:bookmark, user: user, dog: dog, recipe: recipe)

    bookmark = build(:bookmark, user: user, dog: dog, recipe: recipe)

    expect(bookmark).not_to be_valid
  end
end
