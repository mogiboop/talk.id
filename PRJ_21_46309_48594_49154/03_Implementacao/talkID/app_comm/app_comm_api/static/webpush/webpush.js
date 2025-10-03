// Based On https://github.com/chrisdavidmills/push-api-demo/blob/283df97baf49a9e67705ed08354238b83ba7e9d3/main.js

import { addMessage } from '../js/addMessageFunction.js';
 
var isPushEnabled = false,
  registration,
  subBtn,
  logoutBtn,
  icon;

window.addEventListener("load", function () {
  subBtn = document.getElementById("notification-button");
  logoutBtn = document.getElementById("logout");
  icon = subBtn.querySelector("i");

  subBtn.addEventListener("click", function () {
    subBtn.disabled = true;
    if (isPushEnabled) {
      return unsubscribe(registration);
    }
    return subscribe(registration);
  });

  logoutBtn.addEventListener("click", function () {
    logout(registration);
  });

  // Do everything if the Browser Supports Service Worker
  if ("serviceWorker" in navigator) {
    const serviceWorker = document.querySelector(
      'meta[name="service-worker-js"]'
    ).content;
    navigator.serviceWorker.register(serviceWorker).then(function (reg) {
      registration = reg;
      initialiseState(reg);
    });
  }
  // If service worker not supported, show warning to the message box
  else {
    subBtn.disabled = false;
  }

  // Once the service worker is registered set the initial state
  function initialiseState(reg) {
    // Are Notifications supported in the service worker?
    if (!reg.showNotification) {
      subBtn.disabled = false;
      return;
    }

    // Check the current Notification permission.
    // If its denied, it's a permanent block until the
    // user changes the permission
    if (Notification.permission === "denied") {
      subBtn.disabled = false;
      return;
    }

    // Check if push messaging is supported
    if (!("PushManager" in window)) {
      // Show a message and activate the button
      subBtn.disabled = false;
      return;
    }

    // We need to get subscription state for push notifications and send the information to server
    reg.pushManager.getSubscription().then(function (subscription) {
      if (subscription) {
        postSubscribeObj("subscribe", subscription, function (response) {
          // Check the information is saved successfully into server
          if (response.status === 201) {
            subBtn.dataset.url = "/unsubscribe/";
            subBtn.disabled = false;
            isPushEnabled = true;
            icon.classList.toggle("fa-bell");
            icon.classList.toggle("fa-bell-slash");
          }
        });
      }
    });
  }
});
function logout(reg) {
  console.log("entrei logout");
  reg.pushManager.getSubscription().then(function (subscription) {
    // Check we have a subscription to unsubscribe
    if (subscription) {
      // Unsubscribe from push notifications
      subscription
      .unsubscribe()
      .then(function (successful) {
        // Prepare data for sending to server
        var browser = navigator.userAgent
          .match(/(firefox|msie|chrome|safari|trident)/gi)[0]
          .toLowerCase();
        var user_agent = navigator.userAgent;
        var data = {
          status_type: "unsubscribe",
          subscription: subscription.toJSON(),
          browser: browser,
          user_agent: user_agent,
        };

        // POST request to server to handle unsubscribe
        fetch("/unsubscribe/", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRFToken": getCookie("csrftoken"),
          },
          body: JSON.stringify(data),
          credentials: "include",
        })
          .then(function (response) {
            if (response.ok) {
              console.log("unsubscribe done");
            } else {
              console.error(
                "Failed to unsubscribe from push notifications:",
                response.statusText
              );
            }
          })
          .catch(function (error) {
            console.error("Error during unsubscribe request:", error);
          });
      })
      .catch(function (error) {
        console.error(
          "Error unsubscribing from push notifications:",
          error
        );
      });
    }
  });
}

function subscribe(reg) {
  // Get the Subscription or register one
  reg.pushManager.getSubscription().then(function (subscription) {
    var metaObj, applicationServerKey, options;
    // Check if Subscription is available
    if (subscription) {
      return subscription;
    }

    metaObj = document.querySelector('meta[name="django-webpush-vapid-key"]');
    applicationServerKey = metaObj.content;
    options = {
      userVisibleOnly: true,
    };
    if (applicationServerKey) {
      options.applicationServerKey = urlB64ToUint8Array(applicationServerKey);
    }
    // If not, register one
    reg.pushManager
      .subscribe(options)
      .then(function (subscription) {
        postSubscribeObj("subscribe", subscription, function (response) {
          // Check the information is saved successfully into server
          if (response.status === 201) {
            subBtn.dataset.url = "/unsubscribe/";
            subBtn.disabled = false;
            isPushEnabled = true;
            icon.classList.toggle("fa-bell");
            icon.classList.toggle("fa-bell-slash");
            
            addMessage(
              "Your browser notifications for SOS messages were successfully turned on!",
              "warning"
            );
          }
        });
      })
      .catch(function () {
        console.log(
          gettext("Error while subscribing to push notifications."),
          arguments
        );
      });
  });
}

function urlB64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding)
    .replace(/\-/g, "+")
    .replace(/_/g, "/");

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (var i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

function unsubscribe(reg) {
  // Get the Subscription to unregister
  reg.pushManager.getSubscription().then(function (subscription) {
    // Check we have a subscription to unsubscribe
    if (!subscription) {
      // No subscription object, so set the state
      // to allow the user to subscribe to push
      subBtn.disabled = false;
      return;
    }
    postSubscribeObj("unsubscribe", subscription, function (response) {
      // Check if the information is deleted from server
      if (response.status === 202) {
        // Get the Subscription
        // Remove the subscription
        subscription
          .unsubscribe()
          .then(function (successful) {
            subBtn.dataset.url = "/subscribe/";
            isPushEnabled = false;
            subBtn.disabled = false;
            icon.classList.toggle("fa-bell");
            icon.classList.toggle("fa-bell-slash");
            
            addMessage(
              "Your browser notifications were turned off. Turn back on to receive SOS messages.",
              "warning"
            );
            
          })
          .catch(function (error) {
            subBtn.disabled = false;
          });
      }
    });
  });
}

function postSubscribeObj(statusType, subscription, callback) {
  // Send the information to the server with fetch API.
  // the type of the request, the name of the user subscribing,
  // and the push subscription endpoint + key the server needs
  // to send push messages
  var browser = navigator.userAgent
      .match(/(firefox|msie|chrome|safari|trident)/gi)[0]
      .toLowerCase(),
    user_agent = navigator.userAgent,
    data = {
      status_type: statusType,
      subscription: subscription.toJSON(),
      browser: browser,
      user_agent: user_agent,
    };
  fetch(subBtn.dataset.url, {
    method: "post",
    headers: {
      "Content-Type": "application/json",
      "X-CSRFToken": getCookie("csrftoken"),
    },
    body: JSON.stringify(data),
    credentials: "include",
  }).then(callback);
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
