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

  it "レシピ詳細が表示される" do
  recipe = create(:recipe)

  get recipe_path(recipe)

  expect(response).to have_http_status(:ok)
end

it "条件に一致するレシピだけ表示される" do
  recipe1 = create(:recipe,
    age_stage: :adult,
    body_type: :normal,
    activity_level: :medium
  )

  recipe2 = create(:recipe,
    age_stage: :puppy,
    body_type: :normal,
    activity_level: :medium
  )

  get recipes_path, params: {
    age_stage: "adult",
    body_type: "normal",
    activity_level: "medium"
  }

  expect(response.body).to include(recipe1.name)
  expect(response.body).not_to include(recipe2.name)
end
end
