// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Bootstrapをグローバルに設定（削除確認ダイアログで使用）
window.bootstrap = bootstrap

// Swiperのインポート
import Swiper from 'swiper/bundle';
import 'swiper/css/bundle';

//  Turboが読み込まれた後にSwiperを初期化
document.addEventListener("turbo:load", () => {
  // Swiperの初期化
  const swiper = new Swiper('.dog-swiper', {
    // スライドの設定
    slidesPerView: 1,        // 一度に表示するスライド数
    spaceBetween: 30,        // スライド間の余白（ピクセル）
    
    // ループ設定
    loop: true,              // 最後のスライドの次に最初のスライドに戻る
    
    // ナビゲーションボタン（前へ・次へ）
    navigation: {
      nextEl: '.swiper-button-next',  // 次へボタン
      prevEl: '.swiper-button-prev',  // 前へボタン
    },
    
    // ページネーション（下の丸いボタン）
    pagination: {
      el: '.swiper-pagination',       // ページネーション要素
      clickable: true,                // クリックで移動可能
    },
    
    autoplay: {
      delay: 3000,
      disableOnInteraction: false,
    },
  });
});