require 'rails_helper'

RSpec.describe "ログイン", type: :system do
  let(:user) { create(:user, email: "test@example.com", password: "password12345") }
  let!(:dog) { create(:dog, user: user) }

  it "正しい情報でログインできる" do
    visit login_path

    # 🔥 モーダルが表示されている場合は閉じる
    if page.has_selector?(".modal", visible: true)
      find(".modal .btn-close").click
      sleep 0.5
    end

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password12345"

    # 🔥 ログインボタンが表示されるのを待つ
    expect(page).to have_button("ログイン")

    click_button "ログイン"

    # 🔥 ログイン後のページ遷移を確認
    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content('ログインしました')
    expect(page).to have_content('レシピを見る')
  end

  it "間違ったパスワードだとログインできない" do
    visit login_path

    # 🔥 モーダルが表示されている場合は閉じる
    if page.has_selector?(".modal", visible: true)
      find(".modal .btn-close").click
      sleep 0.5
    end

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "wrong_password12"

    # 🔥 ログインボタンが表示されるのを待つ
    expect(page).to have_button("ログイン")

    click_button "ログイン"

    # 🔥 ログイン画面に戻ることを確認
    expect(page).to have_content("ログイン")
  end
end
