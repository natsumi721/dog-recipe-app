require 'rails_helper'

RSpec.describe Dog, type: :model do
  it "有効な犬は保存できる" do
    dog = build(:dog)
    expect(dog).to be_valid
  end

  it "nameがないと無効" do
    dog = build(:dog, name: nil)
    expect(dog).to be_invalid
  end

  it "sizeがないと無効" do
    dog = build(:dog, size: nil)
    expect(dog).to be_invalid
  end

  it "age_stageがないと無効" do
    dog = build(:dog, age_stage: nil)
    expect(dog).to be_invalid
  end
end
