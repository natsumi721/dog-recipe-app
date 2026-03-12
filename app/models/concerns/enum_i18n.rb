module EnumI18n
  extend ActiveSupport::Concern

  class_methods do
    def enum_i18n(enum_name)
      # クラスメソッド: 選択肢を取得
      define_singleton_method("#{enum_name.to_s.pluralize}_i18n") do
        send(enum_name.to_s.pluralize).keys.map do |key|
          [ I18n.t("activerecord.enums.#{model_name.i18n_key}.#{enum_name}.#{key}"), key ]
        end
      end

      # インスタンスメソッド: 現在の値を日本語化
      define_method("#{enum_name}_i18n") do
        I18n.t("activerecord.enums.#{self.class.model_name.i18n_key}.#{enum_name}.#{send(enum_name)}")
      end
    end
  end
end
