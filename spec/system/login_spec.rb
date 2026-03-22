require 'rails_helper'

RSpec.describe "ログイン", type: :system do
  let(:user) { create(:user, email: "test@example.com", password: "password") }

  it "正しい情報でログインできる" do
    visit login_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"

    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content("ログアウト") # ログイン成功の証拠
  end

  it "間違ったパスワードだとログインできない" do
    visit login_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "wrong_password"
    click_button "ログイン"

    expect(page).to have_content("ログイン") # 画面戻る
  end
end