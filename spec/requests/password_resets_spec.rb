require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  let(:user) { create(:user, email: "test@example.com", password: "password123", password_confirmation: "password123") }

  describe "GET /edit" do
    it "returns http success" do
      # 有効なトークンを生成
      user.generate_reset_password_token!

      # トークンを使って編集ページにアクセス
      get edit_password_reset_path(id: user.reset_password_token)

      expect(response).to have_http_status(:success)
    end
  end
end
