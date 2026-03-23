require 'rails_helper'

RSpec.describe "Bookmarks", type: :request do
  let(:user) { create(:user) }
  let!(:dog1) { create(:dog, user: user) }
  let!(:dog2) { create(:dog, user: user) }
  let!(:recipe) { create(:recipe) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(user)
  end

  describe "POST /bookmarks" do
    it "ブックマークを作成できる" do
      expect {
        post bookmarks_path, params: { recipe_id: recipe.id, dog_id: dog1.id }
      }.to change(Bookmark, :count).by(1)
    end

    it "犬が違えば同じレシピでも登録できる" do
      create(:bookmark, user: user, recipe: recipe, dog: dog1)

      expect {
        post bookmarks_path, params: { recipe_id: recipe.id, dog_id: dog2.id }
      }.to change(Bookmark, :count).by(1)
    end
  end

  describe "DELETE /bookmarks/:id" do
    it "ブックマークを削除できる" do
      bookmark = create(:bookmark, user: user, recipe: recipe, dog: dog1)

      expect {
        delete bookmark_path(bookmark)
      }.to change(Bookmark, :count).by(-1)
    end
  end
end