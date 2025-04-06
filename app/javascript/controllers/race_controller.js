import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "startButton",
    "input",
    "completionMessage",
    "formattedChar",
  ];

  connect() {
    this.unformattedRaceBody = this.element.dataset.raceBody;

    document.addEventListener("countdown:finished", () => {
      this.enableTyping();
    });
  }

  disconnect() {
    document.removeEventListener("countdown:finished", () => {
      this.enableTyping();
    });
  }

  enableTyping() {
    this.inputTarget.disabled = false;
    this.inputTarget.focus();
    this.startTime = new Date();
  }

  hideStartButton() {
    this.startButtonTarget.style.display = "none";
  }

  handleInput(event) {
    const inputValue = event.target.value;

    // start from a clean slate for each keystroke
    this.formattedCharTargets.forEach((el) => {
      el.classList.remove(
        "text-green-600",
        "text-red-600",
        "bg-red-200",
        "underline"
      );
    });

    /* 
      loop through the entire input, for each character in the input
      - if the character is correct, add the green class
      - if the character is incorrect, add the red class
      - if the character is the same as the input, add the underline class
      - if the character is not in the input, do nothing
    */
    for (let i = 0; i < this.formattedCharTargets.length; i++) {
      // there is no input so nothing needs to be done
      if (i >= inputValue.length) return;

      if (inputValue[i] === this.unformattedRaceBody[i]) {
        this.formattedCharTargets[i].classList.add("text-green-600");
      } else {
        this.formattedCharTargets[i].classList.add(
          "text-red-600",
          "bg-red-200"
        );
      }

      // character is the same as last character so this is our current position
      if (i === inputValue.length) {
        this.formattedCharTargets[i].classList.add("underline");
      }
    }

    // somebody won!
    if (inputValue === this.unformattedRaceBody) {
      this.endtime = new Date();

      this.inputTarget.disabled = true;
      this.completionMessageTarget.classList.remove("hidden");
      this.completionMessageTarget.classList.add("block");

      this.submitResults();
    }
  }

  submitResults() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    try {
      fetch(`/races/${this.element.dataset.raceId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          completed: true,
          started_at: this.startTime,
          finished_at: this.endtime,
        }),
      })
        .then((response) => response.json())
        .then((data) => console.log({ data }))
        .catch((error) => {
          console.error("Error:", error);
        });
    } catch (error) {
      console.error("Error:", error);
    }
  }
}
