require 'rails_helper'

RSpec.describe "UserSessions", type: :request do
  let(:user) { create(:user, email: "test@example.com", password: "password") }

  describe "POST /login" do
    it "正しい情報でログインできる" do
      post login_path, params: {
        email: user.email,
        password: "password"
      }

      expect(response).to redirect_to(dashboard_path)
    end

    it "間違ったパスワードだとログインできない" do
      post login_path, params: {
        email: user.email,
        password: "wrong_password"
      }

      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:ok)
      expect(response.body).to include("ログイン") # ログイン画面に戻る
    end
  end
end