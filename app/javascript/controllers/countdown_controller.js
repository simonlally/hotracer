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

        const countdownFinishedEvent = new CustomEvent("countdown:finished", {
          bubbles: true,
        });

        this.element.dispatchEvent(countdownFinishedEvent);

        setTimeout(() => {
          this.bodyTarget.textContent = "";
        }, 1000);
      }
    }, 1000);
  }
}
