require 'rails_helper'

RSpec.describe "Bookmark", type: :system do
  let(:user) { create(:user, password: "password") }
  let!(:dog) { create(:dog, user: user) }
  let!(:recipe) { create(:recipe) }

  it "ログインユーザーはブックマークできる" do
    visit login_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログインする"
    expect(page).to have_current_path(dashboard_path)


    visit recipe_path(recipe, dog_id: dog.id)

    expect(page).to have_content("ブックマーク")

    click_link "🦴 ブックマーク 🦴"
  end

  it "未ログインユーザーにはボタンが表示されない" do
    visit recipe_path(recipe)

    expect(page).not_to have_button("ブックマーク")
  end
end
