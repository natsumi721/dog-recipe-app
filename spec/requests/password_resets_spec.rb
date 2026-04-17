require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  let(:user) { create(:user) }

  describe "POST /password_resets" do
    it "登録済みメールならリダイレクトされる" do
      post password_resets_path, params: { email: user.email }
      expect(response).to redirect_to(login_path)
    end

    it "未登録でも同じ挙動（セキュリティ）" do
      post password_resets_path, params: { email: "unknown@example.com" }
      expect(response).to redirect_to(login_path)
    end

    it "メールが送信される" do
      expect {
        post password_resets_path, params: { email: user.email }
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  describe "GET /password_resets/:token/edit" do
    it "有効なトークンなら成功" do
      user.deliver_reset_password_instructions!
      mail = ActionMailer::Base.deliveries.last

      token = mail.body.encoded[/password_resets\/(.+?)\//, 1]

      get edit_password_reset_path(token)

      expect(response).to have_http_status(:ok)
    end

    it "無効なトークンはリダイレクト" do
      get edit_password_reset_path("invalidtoken")
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /password_resets/:token" do
    it "パスワード変更できる" do
      user.deliver_reset_password_instructions!
      mail = ActionMailer::Base.deliveries.last

      token = mail.body.encoded[/password_resets\/(.+?)\//, 1]

      patch password_reset_path(token), params: {
        user: {
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to redirect_to(login_path)
    end

    it "バリデーションエラーで失敗" do
      user.deliver_reset_password_instructions!
      mail = ActionMailer::Base.deliveries.last

      token = mail.body.encoded[/password_resets\/(.+?)\//, 1]

      patch password_reset_path(token), params: {
        user: {
          password: "short",
          password_confirmation: "short"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
