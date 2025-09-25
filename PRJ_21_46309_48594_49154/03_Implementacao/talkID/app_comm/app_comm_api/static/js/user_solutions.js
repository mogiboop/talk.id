let beginDatetimeFilter = '';
let endDatetimeFilter = '';

document.addEventListener("DOMContentLoaded", () => {
  const inputField = document.getElementById("user_autocomplete");
  const datalist = document.getElementById("users");
  const hiddenInput = document.getElementById("selected_user_id");
  const container = document.getElementById("report-container");

  inputField.addEventListener("input", function () {
    const inputValue = this.value.trim().toLowerCase();
    const options = datalist.getElementsByTagName("option");

    for (let i = 0; i < options.length; i++) {
      const option = options[i];
      if (option.value.trim().toLowerCase() === inputValue) {
        hiddenInput.value = option.dataset.id;
        break;
      }
    }
  });
  
  document.getElementById("get-button").addEventListener("click", () => {
    var userID = document.getElementById("selected_user_id").value;
    var bdt = document.getElementById("begin-datetime-filter").value;
    var edt = document.getElementById("end-datetime-filter").value;
    clear();
    if (userID) {
      const params = new URLSearchParams();
      if(bdt){
        params.append('bdt', bdt);
      }
      if(edt){
        params.append('edt', edt);
      }
      fetch(`/app_comm_api/getUserSolutions/${userID}?${params.toString()}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": getCookie("csrftoken"),
        },
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.success) {
            createMessageElements(data.data);
          } else {
            console.error("Failed to update message visibility");
          }
        })
        .catch((error) => console.error("Error fetching messages:", error));
    } else {
      document.getElementById("no-solutions").style.display = "block";
    }
  });

  document.getElementById("clear-button").addEventListener("click", () => {
    clear();
    document.getElementById("begin-datetime-filter").value = '';
    document.getElementById("end-datetime-filter").value = '';
    document.getElementById("end-datetime-filter").disabled = true;
  });

  // Better user experience only allowing to put an end datetime filter if begin datetime filter is set
  document
    .getElementById("begin-datetime-filter")
    .addEventListener("input", function () {
      const beginDatetime = this.value.trim();
      const endDatetimeInput = document.getElementById("end-datetime-filter");

      if (beginDatetime) {
        endDatetimeInput.disabled = false;
        endDatetimeInput.min = beginDatetime;
      } else {
        endDatetimeInput.value = "";
        endDatetimeInput.disabled = true;
        endDatetimeInput.removeAttribute("min");
      }
    });

  function clear() {
    container.innerHTML = "";
    const noSolutionsElement = document.createElement("p");

    
    noSolutionsElement.id = "no-solutions";
    noSolutionsElement.className = "text-center mt-2";
    noSolutionsElement.style.display = "none";

    
    noSolutionsElement.textContent = "No solutions available.";
    container.appendChild(noSolutionsElement);
  }

  function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== "") {
      const cookies = document.cookie.split(";");
      for (let i = 0; i < cookies.length; i++) {
        const cookie = cookies[i].trim();
        if (cookie.substring(0, name.length + 1) === name + "=") {
          cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
          break;
        }
      }
    }
    return cookieValue;
  }

  function createMessageElements(messages) {
    const container = document.getElementById("report-container");
    if (messages.length > 0) {
      messages.forEach((message) => {
        const messageDetails = document.createElement("div");
        messageDetails.classList.add("card", "mb-3");

        const messageHeader = document.createElement("div");
        messageHeader.classList.add("card-header", "bg-info", "text-white");

        const headerContent = document.createElement("div");
        headerContent.classList.add(
          "d-flex",
          "justify-content-between",
          "align-items-center"
        );

        const badges = document.createElement("div");

        const typeBadge = document.createElement("span");
        typeBadge.classList.add("badge", "badge-light", "mr-2");
        typeBadge.textContent = `Type: ${message.message_type_name}`;
        badges.appendChild(typeBadge);

        if (message.level) {
          const levelBadge = document.createElement("span");
          levelBadge.classList.add("badge", "badge-secondary", "mr-2");
          levelBadge.textContent = `Level: ${message.level}`;
          badges.appendChild(levelBadge);
        }

        const datetime = document.createElement("small");
        datetime.textContent = message.formatted_date_time;

        headerContent.appendChild(badges);
        headerContent.appendChild(datetime);
        messageHeader.appendChild(headerContent);
        messageDetails.appendChild(messageHeader);

        const messageContent = document.createElement("div");
        messageContent.classList.add("card-body");

        const messageText = document.createElement("p");
        messageText.classList.add("card-text");
        messageText.textContent = message.message_info;
        messageContent.appendChild(messageText);

        if (message.message_solutions && message.message_solutions.length > 0) {
          const solutionsContainer = document.createElement("div");
          solutionsContainer.classList.add("mt-3");

          const solutionsHeader = document.createElement("h5");
          solutionsHeader.classList.add("card-subtitle", "mb-2", "text-muted");
          solutionsHeader.textContent = "Solutions";
          solutionsContainer.appendChild(solutionsHeader);

          message.message_solutions.forEach((solution) => {
            const solutionElement = document.createElement("div");
            solutionElement.classList.add(
              "solution-element",
              "border",
              "rounded",
              "p-2",
              "mb-2"
            );

            const solutionText = document.createElement("p");
            solutionText.classList.add("mb-1");
            solutionText.textContent = solution.message_solution;
            solutionElement.appendChild(solutionText);

            const solutionInfo = document.createElement("div");
            solutionInfo.classList.add(
              "d-flex",
              "justify-content-end",
              "text-muted"
            );
            const solutionProvider = document.createElement("small");
            solutionProvider.textContent = `Provided by: ${solution.first_name} ${solution.last_name} (${solution.username})`;
            solutionInfo.appendChild(solutionProvider);
            solutionElement.appendChild(solutionInfo);

            solutionsContainer.appendChild(solutionElement);
          });

          messageContent.appendChild(solutionsContainer);
        }

        messageDetails.appendChild(messageContent);
        container.appendChild(messageDetails);
      });
    } else {
      document.getElementById("no-solutions").style.display = "block";
    }
  }
});
