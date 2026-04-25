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

// 🔥 未ログイン時の「アプリの使い方」モーダル表示
function showHowToUseModal() {
  console.log("showHowToUseModal called");

  // 未ログイン状態かどうかを確認
  const isLoggedIn = document.querySelector('body').dataset.loggedIn === 'true';
  
  if (isLoggedIn) {
    console.log("User is logged in, skipping modal");
    return;
  }

  // 初回訪問かどうかを確認
  const hasVisited = localStorage.getItem("hasVisitedBefore");
  console.log("hasVisited:", hasVisited);

  if (hasVisited) {
    console.log("Already visited, skipping modal");
    return;
  }

  // モーダル要素を取得
  const modal = document.getElementById("howToUseModal");
  if (!modal) {
    console.log("Modal not found");
    return;
  }

  console.log("Showing modal");
  const bsModal = new bootstrap.Modal(modal);
  bsModal.show();

  // 訪問済みフラグを設定
  localStorage.setItem("hasVisitedBefore", "true");
}

// 両方のイベントで実行
document.addEventListener("turbo:load", showHowToUseModal);
document.addEventListener("DOMContentLoaded", showHowToUseModal);


// ローディング中
// DOMContentLoadedとturbo:loadの両方に対応
document.addEventListener("DOMContentLoaded", setupDogFormLoading);
document.addEventListener("turbo:load", setupDogFormLoading);

function setupDogFormLoading() {
  // フォーム、ボタン、ローディング表示を取得
  const form = document.querySelector("form[action*='dogs']");
  const submitButton = document.getElementById("dog-submit-button");
  const loadingIndicator = document.getElementById("loading-indicator");

  // 要素が存在しない場合は処理を終了
  if (!form || !submitButton || !loadingIndicator) return;

  // フォーム送信時の処理
  form.addEventListener("submit", (event) => {
    // ファイルが選択されているかチェック
    const fileInput = form.querySelector("input[type='file']");
    const hasFile = fileInput && fileInput.files.length > 0;

    // 画像削除チェックボックスがチェックされているかを確認
    const removeCheckbox = form.querySelector("input[name='dog[remove_avatar]']");
    const isRemoving = removeCheckbox && removeCheckbox.checked;

    // ファイルが選択されているか、画像削除が選択されている場合のみローディング表示
    if (hasFile || isRemoving) {
      // ボタンを無効化
      submitButton.disabled = true;
      submitButton.classList.add("opacity-50");
      submitButton.style.cursor = "not-allowed";
      
      // ボタンのテキストを変更
      if (hasFile) {
        submitButton.value = "アップロード中...";
      } else if (isRemoving) {
        submitButton.value = "削除中...";
      }

      // ローディング表示を表示
      loadingIndicator.classList.remove("hidden");

      // ローディング表示までスクロール
      loadingIndicator.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  });
}