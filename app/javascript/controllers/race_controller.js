import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "startButton",
    "input",
    "completionMessage",
    "formattedChar",
    "wordsPerMinute",
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

  disableStartButton() {
    this.startButtonTarget.classList.add("disabled");
    this.startButtonTarget.classList.remove(
      "bg-green-600",
      "hover:bg-green-700",
      "hover:cursor-pointer"
    );
    this.startButtonTarget.classList.add(
      "bg-gray-400",
      "cursor-not-allowed",
      "opacity-60"
    );
  }

  handleInput(event) {
    const inputValue = event.target.value;

    this.formattedCharTargets.forEach((el) => {
      el.classList.remove(
        "text-green-600",
        "text-red-600",
        "bg-red-200",
        "underline"
      );
    });

    for (let i = 0; i < this.formattedCharTargets.length; i++) {
      if (i >= inputValue.length) return;

      if (inputValue[i] === this.unformattedRaceBody[i]) {
        this.formattedCharTargets[i].classList.add("text-green-600");
      } else {
        this.formattedCharTargets[i].classList.add(
          "text-red-600",
          "bg-red-200"
        );
      }

      // current_character is set when the length of the input is equal to the current_index
      if (i === inputValue.length) {
        this.formattedCharTargets[i].classList.add("underline");
      }

      this.renderWordsPerMinute();
    }

    if (inputValue === this.unformattedRaceBody) {
      this.endtime = new Date();
      this.inputTarget.disabled = true;

      this.submitResults();
    }
  }

  calculateWordsPerMinute() {
    /* 
      according to https://www.speedtypingonline.com/typing-equations
      the formula for calculating wpm is => characters typed / 5 (avg characters per word) / time in minutes
      for now we'll only calculate wpm and not accuracy
    */

    const currentTime = new Date();
    const elapsedTimeInMilliseconds = currentTime - this.startTime;
    const charactersTyped = this.inputTarget.value.length;
    const elapsedTimeInMinutes = elapsedTimeInMilliseconds / 1000 / 60;
    const wordsPerMinute = Math.round(
      charactersTyped / 5 / elapsedTimeInMinutes
    );
    return wordsPerMinute;
  }

  renderWordsPerMinute() {
    this.wordsPerMinute = this.calculateWordsPerMinute();

    this.wordsPerMinuteTarget.innerText =
      "Words per minute: " + this.wordsPerMinute;
  }

  submitResults() {
    // https://fly.io/ruby-dispatch/turbostream-fetch/
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    try {
      fetch(
        `/participations/${this.element.dataset.raceCurrentParticipationId}`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrfToken,
          },
          body: JSON.stringify({
            completed: true,
            started_at: this.startTime,
            finished_at: this.endtime,
            words_per_minute: this.wordsPerMinute,
          }),
        }
      )
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
