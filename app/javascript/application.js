// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Bootstrapをグローバルに設定（削除確認ダイアログで使用）
window.bootstrap = bootstrap
