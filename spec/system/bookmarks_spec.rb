require 'rails_helper'

RSpec.describe "Bookmark", type: :system do
  let(:user) { create(:user, password: "password") }
  let!(:dog) { create(:dog, user: user) }
  let!(:recipe) { create(:recipe) }

  it "ログインユーザーはブックマークできる" do
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "ログイン"

    visit recipe_path(recipe, dog_id: dog.id)

    click_button "ブックマーク"

    expect(page).to have_content("ブックマークしました")
  end

  it "未ログインユーザーにはボタンが表示されない" do
    visit recipe_path(recipe)

    expect(page).not_to have_button("ブックマーク")
  end
end