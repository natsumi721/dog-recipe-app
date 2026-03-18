class Recipe < ApplicationRecord
  belongs_to :user, optional: true

  # enum :size, { small: 0, medium: 1, large: 2 }, prefix: true
  enum :age_stage, { puppy: 0, adult: 1, senior: 2 }, prefix: true
  enum :body_type, { thin: 0, normal: 1, overweight: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true

  include EnumI18n
  # enum の日本語化を有効にする
  enum_i18n :size
  enum_i18n :age_stage
  enum_i18n :body_type
  enum_i18n :activity_level


  validates :name, presence: true
  validates :description, presence: true

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by_users, through: :bookmarks, source: :user

  # サイズ別の材料を取得するメソッド
  def ingredients_for_size(size)
    return "" if ingredients.blank?

    # 材料テキストを行ごとに分割
    lines = ingredients.split("\n")

    # サイズごとのセクションを探す
    size_patterns = case size.to_sym
    when :small then [ "■ 小型犬", "▪ 小型犬" ]
    when :medium then [ "■ 中型犬", "▪ 中型犬" ]
    when :large then [ "■ 大型犬", "▪ 大型犬" ]
    else return ""
    end

    # 該当サイズのセクションを抽出
    in_section = false
    result_lines = []

    lines.each do |line|
      # セクションの開始を検出
      if size_patterns.any? { |pattern| line.include?(pattern) }
        in_section = true
        next
      end

      # 次のセクションが始まったら終了
      if in_section && line.strip.start_with?("■")
        break
      end

      # セクション内の行を収集
      if in_section && line.strip.present?
        result_lines << line.strip
      end
    end

    result_lines.join("\n")
  end

  # 材料の見出し部分（「【2日分（4食分）目安】」など）を取得
  def ingredients_header
    return "" if ingredients.blank?

    lines = ingredients.split("\n")
    lines.first&.strip || ""
  end
end
