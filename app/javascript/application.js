// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Bootstrapをグローバルに設定（削除確認ダイアログで使用）
window.bootstrap = bootstrap

// 🔥 Swiperを初期化する関数（CDN版）
function initSwiper() {
  
  const swiperElement = document.querySelector('.top-dog-swiper');
  
  if (!swiperElement) {
    console.log('Swiper element not found');
    return;
  }

  const slideCount = document.querySelectorAll('.top-dog-swiper .swiper-slide').length;
  
  // 🔥 Swiperが読み込まれているか確認
  if (typeof window.Swiper === 'undefined') {
    console.error('Swiper is not loaded!');
    return;
  }
  
  if (slideCount > 1) {
    // 🔥 CDN版のSwiperを使う
    const swiper = new window.Swiper('.top-dog-swiper', {
      loop: true,
      autoplay: {
        delay: 3000,
        disableOnInteraction: false,
      },
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },
      pagination: {
        el: '.swiper-pagination',
        clickable: true,
      },
    });
    
  } else {
    console.log('Swiper not initialized: Only one slide');
  }
}

// 🔥 ページ読み込み時にSwiperを初期化
window.addEventListener('DOMContentLoaded', initSwiper);
window.addEventListener('turbo:load', initSwiper);