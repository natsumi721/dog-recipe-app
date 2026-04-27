// スクロールで要素を表示する処理
document.addEventListener('turbo:load', () => {
  const revealItems = document.querySelectorAll('.scroll-reveal-item');
  
  // Intersection Observer API を使用
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.2 // 要素の20%が表示されたら発火
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        // 一度表示されたら監視を解除(再度非表示にしない)
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);
  
  // 各要素を監視
  revealItems.forEach(item => {
    observer.observe(item);
  });
});