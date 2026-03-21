require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  let(:user) { create(:user) }

  context "未ログインでフィルタ条件あり" do
    it "レシピが表示される" do
      get recipes_path, params: {
        age_stage: "adult",
        body_type: "normal",
        activity_level: "medium"
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
