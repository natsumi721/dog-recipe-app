require 'rails_helper'

RSpec.describe User, type: :model do
  it "有効なユーザーは保存できる" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "emailがないと無効" do
    user = build(:user, email: nil)
    expect(user).to be_invalid
  end

  it "passwordが6文字未満だと無効" do
    user = build(:user, password: "123", password_confirmation: "123")
    expect(user).to be_invalid
  end

  it "password_confirmationがないと無効" do
    user = build(:user, password_confirmation: nil)
    expect(user).to be_invalid
  end

  it "ユーザーは複数の犬を持てる" do
    user = create(:user)
    create_list(:dog, 2, user: user)

    expect(user.dogs.count).to eq(2)
  end
end
