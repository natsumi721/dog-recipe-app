require 'rails_helper'

RSpec.describe "Dashboard", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)

    # ログイン再現
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(user)
  end

  it "犬が1頭ならレシピ一覧に飛ぶリンクが出る" do
    dog = create(:dog, user: user)

    visit dashboard_path

    expect(page).to have_link(
      "レシピを見る",
      href: recipes_path(dog_id: dog.id)
    )
  end

  it "犬が複数なら選択画面リンクが出る" do
    create_list(:dog, 2, user: user)

    visit dashboard_path

    expect(page).to have_link(
      "レシピを見る",
      href: select_dog_recipes_path
    )
  end
end
