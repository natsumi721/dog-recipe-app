class ChangeAllergiesTypeInDogsFixed < ActiveRecord::Migration[7.0]
  def up
    # ステップ1: 一時カラムを追加
    add_column :dogs, :allergies_temp, :string, array: true, default: []
    
    # ステップ2: 既存データを配列に変換して一時カラムに保存
    Dog.find_each do |dog|
      next if dog.allergies.blank?
      
      begin
        # JSON文字列を配列に変換
        allergies_array = JSON.parse(dog.allergies)
        dog.update_column(:allergies_temp, allergies_array)
      rescue JSON::ParserError
        # JSON解析エラーの場合は空配列を設定
        dog.update_column(:allergies_temp, [])
      end
    end
    
    # ステップ3: 元のカラムを削除
    remove_column :dogs, :allergies
    
    # ステップ4: 一時カラムの名前を変更
    rename_column :dogs, :allergies_temp, :allergies
  end
  
  def down
    # ロールバック処理
    add_column :dogs, :allergies_temp, :text
    
    Dog.find_each do |dog|
      next if dog.allergies.blank?
      
      # 配列をJSON文字列に変換
      allergies_json = dog.allergies.to_json
      dog.update_column(:allergies_temp, allergies_json)
    end
    
    remove_column :dogs, :allergies
    rename_column :dogs, :allergies_temp, :allergies
  end
end