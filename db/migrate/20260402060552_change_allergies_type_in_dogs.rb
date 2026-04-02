class ChangeAllergiesTypeInDogs < ActiveRecord::Migration[7.2]
  def up
    # 既存のデータを修正
    Dog.find_each do |dog|
      allergies = dog.attributes['allergies']

      # 空文字列の場合は空配列に変換
      if allergies.blank?
        dog.update_column(:allergies, '[]')
      # JSON配列形式でない場合は配列に変換
      elsif allergies.is_a?(String) && !allergies.start_with?('[')
        # カンマ区切りの場合は分割して配列化
        if allergies.include?(',')
          items = allergies.split(',').map(&:strip)
          dog.update_column(:allergies, items.to_json)
        else
          # 単一の文字列の場合は配列化
          dog.update_column(:allergies, [ allergies ].to_json)
        end
      end
    end

    # カラム型を変更
    change_column :dogs, :allergies, :jsonb, using: 'allergies::jsonb', default: []
  end

  def down
    change_column :dogs, :allergies, :text
  end
end
