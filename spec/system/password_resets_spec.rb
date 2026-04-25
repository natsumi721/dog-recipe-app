require 'rails_helper'

RSpec.describe "PasswordResets", type: :system do
  it "パスワードリセットできる" do
    ActionMailer::Base.deliveries.clear

    # ユーザーを作成
    user = create(:user)

    visit login_path

    # 🔥 モーダルが表示されている場合は閉じる
    if page.has_selector?(".modal", visible: true)
      find(".modal .btn-close").click
      sleep 0.5
    end

    # 🔥 リンクが表示されるのを待つ
    expect(page).to have_link("パスワード忘れた方")

    # リンクをクリック
    click_on "パスワード忘れた方"

    # ページの読み込みを待つ（パスワードリセット画面のタイトルが表示されるまで待つ）
    expect(page).to have_content("パスワードをお忘れですか")

    # パスワードリセット画面に遷移したか確認
    expect(current_path).to eq(new_password_reset_path)

    # メールアドレスを入力
    fill_in "メールアドレス", with: user.email

    # 🔥 送信ボタンが表示されるのを待つ
    expect(page).to have_button("パスワードリセットメールを送信")

    # 送信ボタンをクリック
    click_on "パスワードリセットメールを送信"

    # ページの読み込みを待つ（フラッシュメッセージが表示されるまで待つ）
    expect(page).to have_content("パスワードリセットのメールを送信しました。")

    # ログイン画面に遷移したか確認
    expect(current_path).to eq(login_path)

    # メールが送信されたことを確認
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end
end
