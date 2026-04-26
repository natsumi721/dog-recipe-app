// app/javascript/how_to.js
document.addEventListener("DOMContentLoaded", () => {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -100px 0px"
  };
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
      }
    });
  }, observerOptions);
  const fadeElements = document.querySelectorAll(".fade-in-section");
  fadeElements.forEach((element) => {
    observer.observe(element);
  });
});
//# sourceMappingURL=/assets/how_to.js.map
