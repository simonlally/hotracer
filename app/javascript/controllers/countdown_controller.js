import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["body"];

  connect() {
    this.startCountdown();
  }

  startCountdown() {
    let currentValue = 3;
    this.bodyTarget.textContent = currentValue;

    const interval = setInterval(() => {
      currentValue -= 1;
      if (currentValue > 0) {
        this.bodyTarget.textContent = currentValue;
      } else {
        this.bodyTarget.textContent = "GO!";
        clearInterval(interval);

        setTimeout(() => {
          this.bodyTarget.style.display = "none";

          const countdownFinishedEvent = new CustomEvent("countdown:finished", {
            bubbles: true, // Important: allows event to bubble up DOM tree
            detail: { raceId: this.element.dataset.raceId },
          });

          this.element.dispatchEvent(countdownFinishedEvent);
        }, 1000);
      }
    }, 1000);
  }
}
