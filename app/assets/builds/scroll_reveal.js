// app/javascript/scroll_reveal.js
document.addEventListener("turbo:load", () => {
  const revealItems = document.querySelectorAll(".scroll-reveal-item");
  const observerOptions = {
    root: null,
    rootMargin: "0px",
    threshold: 0.2
    // 要素の20%が表示されたら発火
  };
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);
  revealItems.forEach((item) => {
    observer.observe(item);
  });
});
//# sourceMappingURL=/assets/scroll_reveal.js.map
