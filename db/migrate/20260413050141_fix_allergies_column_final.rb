class FixAllergiesColumnFinal < ActiveRecord::Migration[7.2]
  def up
    # ✅ allergiesカラムが既に存在し、配列型の場合はスキップ
    if column_exists?(:dogs, :allergies)
      column = columns(:dogs).find { |c| c.name == 'allergies' }

      if column.sql_type == 'character varying[]'
        puts "✅ allergiesカラムは既に正しい配列型です。スキップします。"
        return
      end
    end

    # 不要な一時カラムを削除
    if column_exists?(:dogs, :allergies_temp)
      puts "⚠️  allergies_tempカラムが残っています。削除します..."
      remove_column :dogs, :allergies_temp
    end

    if column_exists?(:dogs, :allergies_new)
      puts "⚠️  allergies_newカラムが残っています。削除します..."
      remove_column :dogs, :allergies_new
    end

    # allergiesカラムの状態を確認
    if column_exists?(:dogs, :allergies)
      puts "📝 allergiesカラムを配列型に変換します..."

      # 一時的なカラムを作成
      add_column :dogs, :allergies_array, :string, array: true, default: []

      # ✅ データ移行（エラーハンドリング強化）
      Dog.find_each do |dog|
        begin
          if dog.allergies.blank?
            dog.update_column(:allergies_array, [])
          elsif dog.allergies.is_a?(String)
            # JSON文字列の場合
            if dog.allergies.start_with?('[')
              allergies_array = JSON.parse(dog.allergies)
              dog.update_column(:allergies_array, allergies_array)
            else
              # 通常の文字列の場合
              dog.update_column(:allergies_array, [ dog.allergies ])
            end
          elsif dog.allergies.is_a?(Array)
            # 既に配列の場合
            dog.update_column(:allergies_array, dog.allergies)
          else
            # それ以外の場合は空配列
            dog.update_column(:allergies_array, [])
          end
        rescue => e
          puts "⚠️  Dog ID:#{dog.id} のデータ変換に失敗しました。空配列を設定します。"
          puts "エラー: #{e.message}"
          dog.update_column(:allergies_array, [])
        end
      end

      # カラム入れ替え
      remove_column :dogs, :allergies
      rename_column :dogs, :allergies_array, :allergies

      puts "✅ allergiesカラムの配列型への変換が完了しました。"
    else
      puts "⚠️  allergiesカラムが存在しません。新規作成します..."
      add_column :dogs, :allergies, :string, array: true, default: []
    end
  end

  def down
    # ロールバック処理(必要に応じて実装)
    if column_exists?(:dogs, :allergies)
      puts "📝 allergiesカラムをtext型に戻します..."

      add_column :dogs, :allergies_text, :text

      Dog.find_each do |dog|
        dog.update_column(:allergies_text, dog.allergies.to_json)
      end

      remove_column :dogs, :allergies
      rename_column :dogs, :allergies_text, :allergies
    end
  end
end
