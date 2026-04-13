class FixAllergiesColumnFinal < ActiveRecord::Migration[7.2]
  def up
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
      column = columns(:dogs).find { |c| c.name == 'allergies' }

      # 既に配列型の場合は何もしない
      if column.sql_type == 'character varying[]'
        puts "✅ allergiesカラムは既に正しい配列型です。"
        return
      end

      puts "📝 allergiesカラムを配列型に変換します..."

      # 一時的なカラムを作成
      add_column :dogs, :allergies_array, :string, array: true, default: []

      # SQLでデータ移行（JSON文字列も考慮）
      execute <<~SQL
        UPDATE dogs
        SET allergies_array =#{' '}
          CASE
            -- NULL または空文字列の場合
            WHEN allergies IS NULL OR allergies = '' THEN '{}'
        #{'    '}
            -- JSON配列文字列の場合（例: '["鶏肉", "小麦"]'）
            WHEN allergies LIKE '[%]' THEN
              -- JSON文字列をPostgreSQLの配列に変換
              (
                SELECT array_agg(elem::text)
                FROM json_array_elements_text(allergies::json) AS elem
              )
        #{'    '}
            -- 通常の文字列の場合
            ELSE ARRAY[allergies]
          END;
      SQL

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

      execute <<~SQL
        UPDATE dogs
        SET allergies_text = array_to_json(allergies)::text;
      SQL

      remove_column :dogs, :allergies
      rename_column :dogs, :allergies_text, :allergies
    end
  end
end
