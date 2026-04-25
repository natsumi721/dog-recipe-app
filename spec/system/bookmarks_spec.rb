require 'rails_helper'

RSpec.describe "Bookmark", type: :system do
  let(:user) { create(:user, password: "password12345") }
  let!(:dog) { create(:dog, user: user) }
  let!(:recipe) { create(:recipe) }

  it "ログインユーザーはブックマークできる" do
    visit login_path

    # 🔥 モーダルが表示されている場合は閉じる
    if page.has_selector?(".modal", visible: true)
      find(".modal .btn-close").click
      sleep 0.5 # モーダルが閉じるのを待つ
    end

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password12345"

    # 🔥 ログインボタンが表示されるのを待つ
    expect(page).to have_button("ログインする")

    click_button "ログインする"

    # 🔥 ログイン後のページ遷移を確認
    expect(page).to have_current_path(dashboard_path)

    visit recipe_path(recipe, dog_id: dog.id)

    # 🔥 ブックマークボタンが表示されるのを待つ
    expect(page).to have_content("ブックマーク")

    click_link "🦴 ブックマーク 🦴"

    # 🔥 ブックマーク成功のメッセージを確認
    expect(page).to have_content("ブックマークしました")
  end

  it "未ログインユーザーにはボタンが表示されない" do
    visit recipe_path(recipe)

    # 🔥 モーダルが表示されている場合は閉じる
    if page.has_selector?(".modal", visible: true)
      find(".modal .btn-close").click
      sleep 0.5
    end

    expect(page).not_to have_button("ブックマーク")
  end
end
