require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user, password: 'password12345', password_confirmation: 'password12345') }
  let!(:dog) { create(:dog, user: user) }  # 犬を作成（let!で事前に作成）

  describe "GET /edit" do
    context "ログインしている場合" do
      before do
        # ログイン処理
        post login_path, params: { email: user.email, password: 'password12345' }

        # リダイレクトをフォロー
        follow_redirect! if response.redirect?
      end

      it "returns http success" do
        get edit_profile_path
        expect(response).to have_http_status(:success)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get edit_profile_path
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
