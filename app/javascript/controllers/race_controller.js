import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countdown", "startButton"];

  connect() {
    console.log("connected");
    this.start();
  }

  start() {
    let currentValue = 3;
    this.countdownTarget.textContent = currentValue;

    const interval = setInterval(() => {
      currentValue -= 1;
      if (currentValue > 0) {
        this.countdownTarget.textContent = currentValue;
      } else {
        this.countdownTarget.textContent = "GO!";
        clearInterval(interval);

        setTimeout(() => {
          this.countdownTarget.style.display = "none";
        }, 1000);
      }
    }, 1000);
  }

  hideStartButton() {
    this.startButtonTarget.style.display = "none";
  }
}
