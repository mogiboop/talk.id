import { addMessage } from "./addMessageFunction.js";

let userFilter = "";
let groupFilter = "";
let offset = 10;

document.addEventListener("DOMContentLoaded", () => {
  const usersList = document.getElementById("users-list");

  const loadMore = document.getElementById("load-more");

  var toggleEmailButtons = document.querySelectorAll(".toggle-email");
  toggleEmailButtons.forEach(function (button) {
    button.addEventListener("click", function () {
      var emailDiv = this.previousElementSibling;
      if (emailDiv.classList.contains("d-none")) {
        emailDiv.classList.remove("d-none");
        this.textContent = "Hide Email";
      } else {
        emailDiv.classList.add("d-none");
        this.textContent = "Show Email";
      }
    });
  });

  if (usersList) {
    usersList.addEventListener("click", function (event) {
      if (event.target.classList.contains("delete-user")) {
        const liElement = event.target.closest("li");
        const userId = liElement.getAttribute("data-id");
        const user = liElement.querySelector("div > div > div.user-username").textContent;

        if (confirm("Are you sure you want to delete this user?")) {
          fetch(`/app_comm_api/delete_user/${userId}/`, {
            method: "DELETE",
            headers: {
              "Content-Type": "application/json",
              "X-CSRFToken": getCookie("csrftoken"),
            },
          })
            .then((response) => {
              if (response.ok) {
                liElement.remove(); 
                addMessage(`User <b>${user}</b> deleted succesfully!`, 'info')
              } else {
                response.json().then((data) => alert(data.detail));
              }
            })
            .catch((error) => {
              console.error("Error:", error);
              addMessage(`Failed to delete user <b>${user}</b>.`, 'danger', false)
            });
        }
      }
    });
  } else {
    document.getElementById("no-users").style.display = "block";
  }

  document.getElementById("reset-button").addEventListener("click", () => {
    if (
      document.getElementById("user-filter").value != "" ||
      document.getElementById("group-filter").value != ""
    ) {
      userFilter = "";
      groupFilter = "";

      document.getElementById("user-filter").value = userFilter;
      document.getElementById("group-filter").value = groupFilter;
      offset = 0;
      getUsersWithFilters(true);
    }
  });

  document.getElementById("filter-button").addEventListener("click", () => {
    if (
      document.getElementById("user-filter").value != userFilter ||
      document.getElementById("group-filter").value != groupFilter
    ) {
      userFilter = document.getElementById("user-filter").value;
      groupFilter = document.getElementById("group-filter").value;
      offset = 0;
      getUsersWithFilters(true);
    }
  });

  if (loadMore) {
    document.getElementById("load-more").addEventListener("click", () => {
      getUsersWithFilters(false);
    });
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
  function hideLoadMore() {
    document.getElementById("load-more").style.display = "none";
  }

  function showLoadMore() {
    document.getElementById("load-more").style.display = "block";
  }
  function getUsersWithFilters(remove) {
    const params = new URLSearchParams();
    params.append("offset", offset);
    if (userFilter) params.append("user", userFilter);
    if (groupFilter) params.append("group", groupFilter);

    fetch(`/app_comm_api/loadMoreUsers?${params.toString()}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": getCookie("csrftoken"),
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          const usersList = document.getElementById("users-list");
          const button = usersList.querySelector("#load-more");
          const users = usersList.querySelectorAll("li.list-group-item");
          if (remove) {
            users.forEach((user) => {
              user.remove();
            });
          }
          if (data.data.length > 0) {
            data.data.slice(0, 10).forEach((user) => {
              // Create <li> element
              var listItem = document.createElement("li");
              listItem.classList.add(
                "list-group-item",
                "d-flex",
                "justify-content-between",
                "align-items-center"
              );
              listItem.setAttribute("data-id", user.id);

              
              var firstDiv = document.createElement("div");

              var innerDiv = document.createElement("div");
              innerDiv.classList.add("d-flex", "flex-column");

              var userName = document.createElement("div");
              userName.classList.add("user-name", "font-weight-bold");
              userName.textContent = user.full_name;

              var userUsername = document.createElement("div");
              userUsername.classList.add("user-username");
              userUsername.textContent = user.username;

              var userGroup = document.createElement("div");
              userGroup.classList.add("user-group", "text-muted");
              userGroup.textContent = user.group;

              var userEmail = document.createElement("div");
              userEmail.classList.add("user-email", "d-none");
              userEmail.textContent = user.email;

              var toggleEmailButton = document.createElement("button");
              toggleEmailButton.classList.add(
                "btn",
                "btn-link",
                "btn-sm",
                "toggle-email"
              );
              toggleEmailButton.textContent = "Show Email";

              
              innerDiv.appendChild(userName);
              innerDiv.appendChild(userUsername);
              innerDiv.appendChild(userGroup);
              innerDiv.appendChild(userEmail);
              innerDiv.appendChild(toggleEmailButton);

              firstDiv.appendChild(innerDiv);

              var deleteButton = document.createElement("button");
              deleteButton.classList.add(
                "btn",
                "btn-danger",
                "btn-sm",
                "delete-user"
              );
              deleteButton.textContent = "Delete";

              listItem.appendChild(firstDiv);
              listItem.appendChild(deleteButton);

              usersList.insertBefore(listItem, button);

              var toggleEmailButton = listItem.querySelector(".toggle-email");
              toggleEmailButton.addEventListener("click", function () {
                var userEmail = listItem.querySelector(".user-email");
                userEmail.classList.toggle("d-none");
                if (userEmail.classList.contains("d-none")) {
                  toggleEmailButton.textContent = "Show Email";
                } else {
                  toggleEmailButton.textContent = "Hide Email";
                }
              });
            });

            if (data.data.length < 11) {
              hideLoadMore();
            } else {
              showLoadMore();
              offset += data.data.length - 1;
            }
            document.getElementById("no-users").style.display = "none";
          } else {
            document.getElementById("no-users").style.display = "block";
          }
        } else {
          console.error("Failed to update message visibility");
        }
      })
      .catch((error) => console.error("Error fetching messages:", error));
  }
});
