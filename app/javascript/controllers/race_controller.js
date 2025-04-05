import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["startButton", "input"];

  connect() {
    console.log("race_controller connected");

    document.addEventListener("countdown:finished", (event) => {
      // console.log("Countdown finished event received");

      // console.log("countdown finished event details:", event.detail);
      const raceId = event.detail.raceId;
      // console.log("race_id:", raceId);

      this.enableTyping();
    });
  }

  disconnect() {
    document.removeEventListener("countdown:finished", this.boundEnableTyping);
  }

  enableTyping() {
    console.log("enableTyping called");
    console.log("input target:", this.inputTarget);

    this.inputTarget.disabled = false;
    this.inputTarget.focus();
  }

  hideStartButton() {
    this.startButtonTarget.style.display = "none";
  }
}
