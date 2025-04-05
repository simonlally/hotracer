import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countdown"];

  connect() {
    console.log("connected");
    this.start();
  }

  start() {
    let currentValue = 3;

    const interval = setInterval(() => {
      if (currentValue > 0) {
        this.countdownTarget.textContent = currentValue;
        currentValue -= 1;
      } else {
        this.countdownTarget.textContent = "GO!";
        clearInterval(interval);

        setTimeout(() => {
          this.countdownTarget.style.display = "none";
        }, 1000);
      }
    }, 1000);
  }
}
