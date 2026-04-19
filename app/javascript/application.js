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

// 使い方ページ、ふわっと浮かび上がるように
function initFadeIn() {
  console.log("fade-in start");

  const elements = document.querySelectorAll(".fade-in-section");
  console.log("Found elements:", elements.length);

  if (elements.length === 0) {
    console.log("No fade-in-section elements found");
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      console.log("Entry:", entry.target, "isIntersecting:", entry.isIntersecting);
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        console.log("Added is-visible to:", entry.target);
      }
    });
  }, {
    threshold: 0.1
  });

  elements.forEach(el => {
    observer.observe(el);

    // 初期表示にも対応
    if (el.getBoundingClientRect().top < window.innerHeight) {
      el.classList.add("is-visible");
      console.log("Initial visible:", el);
    }
  });
}

// 両方のイベントで実行
document.addEventListener("turbo:load", initFadeIn);
document.addEventListener("DOMContentLoaded", initFadeIn);
