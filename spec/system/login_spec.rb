require 'rails_helper'

RSpec.describe "ログイン", type: :system do
  let(:user) { create(:user, email: "test@example.com", password: "password12345") }
  let!(:dog) { create(:dog, user: user) }
  it "正しい情報でログインできる" do
    visit login_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password12345"
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)
  expect(page).to have_content('ログインしました')
  expect(page).to have_content('レシピを見る') # ← ダッシュボードの要素で確認
  end

  it "間違ったパスワードだとログインできない" do
    visit login_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "wrong_password12"
    click_button "ログイン"

    expect(page).to have_content("ログイン") # 画面戻る
  end
end
