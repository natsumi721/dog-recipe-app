# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 例: レシピの初期データを作成
Recipe.destroy_all

Recipe.create!(
  name: "鶏ももと白米のエネルギー補給ごはん",
  size: :medium,
  age_stage: :adult,
  body_type: :thin,
  activity_level: :medium,

  description: "体重を増やしたい痩せ型の成犬向けレシピ",

  ingredients: <<~TEXT,
    【成犬1日分目安】

    ・鶏もも肉 … 120g
    ・白米 … 150g
    ・にんじん … 30g
    ・水 … 適量
  TEXT

  instructions: <<~TEXT,
    ① 炊飯器で白米をやわらかめに炊く
         水の量を少し多めにして炊くと、より柔らかくなります。

    ② 鶏ももをしっかりと火が通るまで茹でる（5〜7分）
        中までしっかりと火が通るように、鶏ももを適当な大きさに切ってから茹でるのがおすすめです。

    ③ にんじんを細かく刻んで茹でる。
       茹でて火を通すか、キッチンペーパーをしっかりと濡らし、人参に包んで電子レンジで加熱してください。
       2分で取り出し、フォークなどで潰せるか確認し、必要に応じてさらに加熱をしてください。

    ④ 炊き上がったご飯と茹でた鶏もも、にんじんをしっかりと混ぜ合わせる。
       愛犬の好みの食感になるように、鶏ももを細かく刻んだり、にんじんを潰したりして調整してください。

    ☆ ひとことアドバイス ☆    
      もし圧力鍋があれば、人参と鶏ももを一緒に加圧調理するのもおすすめです。
       そうすることで、鶏ももから出る旨味が人参に染み込み、より美味しいご飯になります。
       その後、炊き上がったご飯と混ぜ合わせてください。
  TEXT
  nutrition_note: <<~TEXT
    ✔ 鶏もも肉で高タンパク。
    ✔ カロリー増設計
  TEXT
)

Recipe.create!(
  name: "牛肉とさつまいものほくほくごはん",
  size: :medium,
  age_stage: :adult,
  body_type: :thin,
  activity_level: :medium,

  description: "じんわり体重を増やしたい痩せ型の成犬向けレシピ",

  ingredients: <<~TEXT,
    【成犬1日分目安】

    ・牛肉 … 100g
    ・さつまいも … 120g
    ・卵 … 1個
    ・水 … 適量
  TEXT

  instructions: <<~TEXT,
    ① さつまいもを加熱
         さつまいもを1cm角程度に切り、鍋で茹でるか、電子レンジで加熱して柔らかくします。
         フォークで簡単に潰せるくらいまで加熱してください。

    ② 牛肉を茹でる
        カットした牛肉を茹で、脂が浮いてきたら軽くすくいます。
        牛肉がしっかりと火が通るまで茹でてください。

    ③ 卵を調理
        別鍋でゆで卵にする。この時、半熟ではなくしっかりと固ゆでにしてください。
        ゆで卵ができたら、殻をむいて細かく刻むか、フォークで潰しましょう。

    ④ ①②③を混ぜ合わせる。パサつくのが気になる場合は、牛肉を茹でた際のスープを少し加えて調整してください。
  TEXT

  nutrition_note: <<~TEXT
    ✔ 牛肉で高タンパク
    ✔ 卵で必須アミノ酸を強化
    ✔︎ さつまいもで持続エネルギー補給
  TEXT
)

Recipe.create!(
  name: "サーモンとブロッコリーの栄養満点ごはん",
  size: :medium,
  age_stage: :adult,
  body_type: :thin,
  activity_level: :medium,

  description: "体重を増やしたい痩せ型の成犬向けレシピ",

  ingredients: <<~TEXT,
    【成犬1日分目安】
    ・生鮭（皮付き・塩分はNG） … 110g
    ・ブロッコリー … 40g
    ・白米 … 150g
    ・水 … 適量
  TEXT

  instructions: <<~TEXT,
    ① 白米をやわらかめに炊く
        炊飯器で白米をやわらかめに炊いてください。
        水の量を少し多めにして炊くと、より柔らかくなります。

    ② ブロッコリーを加熱
         ブロッコリーを鍋で茹でるか、電子レンジで加熱して柔らかくします。
         房も茎も食べられるように、フォークで簡単に潰せるくらいまで加熱してください。

    ③ 生鮭を加熱
        骨を全て取り除き、２〜３等分に切った生鮭を鍋で茹でます。
        鍋に入れて、水がかぶるくらいの量を加え、弱〜中火で７分ほど火にかけてください。
        脂が多く出る場合には軽く取り除いてください。
        焼いても構いませんが、油を使わずに調理することをおすすめします。

    ④ ①②③を混ぜ合わせます。生鮭を茹でた際のスープを少し加えると、より美味しくなります。
  TEXT

  nutrition_note: <<~TEXT
    ✔ 生鮭でDHAを補給。皮膚と被毛のケア
    ✔ 良質な脂質で自然な体重増加をサポート
    ✔︎ ブロッコリーでビタミン補給
  TEXT
)

