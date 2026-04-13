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

      # データを移行
      Dog.reset_column_information
      Dog.find_each do |dog|
        next if dog.allergies.blank?

        begin
          allergies_data = if dog.allergies.is_a?(Array)
                            dog.allergies
          else
                            JSON.parse(dog.allergies)
          end
          dog.update_column(:allergies_array, allergies_data)
        rescue JSON::ParserError => e
          puts "⚠️  Dog ID:#{dog.id} のデータ変換に失敗しました。空配列を設定します。"
          dog.update_column(:allergies_array, [])
        end
      end

      # 古いカラムを削除
      remove_column :dogs, :allergies

      # 新しいカラムの名前を変更
      rename_column :dogs, :allergies_array, :allergies

      puts "✅ 変換完了しました!"
    else
      # allergiesカラムが存在しない場合は新規作成
      puts "📝 allergiesカラムを新規作成します..."
      add_column :dogs, :allergies, :string, array: true, default: []
      puts "✅ 作成完了しました!"
    end
  end

  def down
    # ロールバック処理(必要に応じて実装)
  end
end
