// スクロールアニメーション
document.addEventListener('DOMContentLoaded', initScrollAnimation);
document.addEventListener('turbo:load', initScrollAnimation); 

function initScrollAnimation() {
    const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
      }
    });
  }, observerOptions);

  // アニメーション対象の要素を監視
  const fadeElements = document.querySelectorAll('.fade-in-section');
  fadeElements.forEach(element => {
    observer.observe(element);
  });
}