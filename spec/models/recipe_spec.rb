require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it "有効なレシピは保存できる" do
    recipe = build(:recipe)
    expect(recipe).to be_valid
  end

  it "nameがないと無効" do
    recipe = build(:recipe, name: nil)
    expect(recipe).to be_invalid
  end

  it "descriptionがないと無効" do
    recipe = build(:recipe, description: nil)
    expect(recipe).to be_invalid
  end
end
