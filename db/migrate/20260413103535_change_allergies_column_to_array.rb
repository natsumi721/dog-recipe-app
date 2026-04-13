class ChangeAllergiesColumnToArray < ActiveRecord::Migration[7.0]
  def up
    # allergies カラムがすでに存在する場合は何もしない
    # 存在しない場合は配列型で作成する
    unless column_exists?(:dogs, :allergies)
      add_column :dogs, :allergies, :string, array: true, default: []
    else
      # カラムが存在する場合、配列型かどうかを確認
      column = connection.columns(:dogs).find { |c| c.name == 'allergies' }

      # 配列型でない場合は、配列型に変更
      unless column.array
        # 一時カラムを作成
        add_column :dogs, :allergies_temp, :string, array: true, default: []

        # 既存データを変換
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

        # 元のカラムを削除
        remove_column :dogs, :allergies

        # 一時カラムの名前を変更
        rename_column :dogs, :allergies_temp, :allergies
      end
    end
  end

  def down
    # ロールバック処理
    if column_exists?(:dogs, :allergies)
      column = connection.columns(:dogs).find { |c| c.name == 'allergies' }

      if column.array
        # 一時カラムを作成
        add_column :dogs, :allergies_temp, :text

        # 配列をJSON文字列に変換
        Dog.find_each do |dog|
          next if dog.allergies.blank?

          allergies_json = dog.allergies.to_json
          dog.update_column(:allergies_temp, allergies_json)
        end

        # 元のカラムを削除
        remove_column :dogs, :allergies

        # 一時カラムの名前を変更
        rename_column :dogs, :allergies_temp, :allergies
      end
    end
  end
end
