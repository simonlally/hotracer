import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["startButton", "input", "body", "completionMessage"];

  startTime = "";
  endtime = "";

  connect() {
    this.formatRaceText();

    document.addEventListener("countdown:finished", (event) => {
      this.enableTyping();
    });
  }

  disconnect() {
    document.removeEventListener("countdown:finished", this.boundEnableTyping);
  }

  formatRaceText() {
    const originalText = this.bodyTarget.textContent.trim();
    this.originalText = originalText;

    const formattedHtml = originalText
      .split("")
      .map((char) => {
        const displayChar = char === " " ? "&nbsp;" : char;
        return `<span class="race-char">${displayChar}</span>`;
      })
      .join("");

    this.bodyTarget.innerHTML = formattedHtml;

    this.charElements = this.bodyTarget.querySelectorAll(".race-char");
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

    // each input we literally have to check the whole text

    this.charElements.forEach((el) => {
      el.classList.remove(
        "text-green-600",
        "text-red-600",
        "bg-red-200",
        "underline"
      );
    });

    for (let i = 0; i < this.charElements.length; i++) {
      if (i >= inputValue.length) return; // there is no input

      if (inputValue[i] === this.originalText[i]) {
        this.charElements[i].classList.add("text-green-600");
      } else {
        this.charElements[i].classList.add("text-red-600", "bg-red-200");
      }

      // keep track of the cursor position
      if (i === inputValue.length) {
        this.charElements[i].classList.add("underline");
      }
    }

    // somebody won!
    if (inputValue === this.originalText) {
      this.endtime = new Date();

      this.inputTarget.disabled = true;
      this.completionMessageTarget.classList.remove("hidden");
      this.completionMessageTarget.classList.add("block");

      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      ).content;

      fetch(`/races/${this.element.dataset.raceId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({
          completed: true,
        }),
      })
        .then((response) => console.log(response))
        .then((data) => {})
        .catch((error) => {
          console.error("Error:", error);
        });
    }
  }
}
