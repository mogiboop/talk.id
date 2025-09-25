export function addMessage(message, type, timeout = true) {
    // Create the main container
    const containerDiv = document.createElement('div');
    containerDiv.classList.add('container', 'mt-4');
    
    // Create the row
    const rowDiv = document.createElement('div');
    rowDiv.classList.add('row');
    
    // Create the column
    const colDiv = document.createElement('div');
    colDiv.classList.add('col-md-8', 'offset-md-2');
    
    // Create the content div
    const contentDiv = document.createElement('div');
    contentDiv.id = 'content';
  
    const alertDiv = document.createElement("div");
    alertDiv.classList.add(
      "alert",
      `alert-${type}`,
      "alert-dismissible",
      "fade",
      "show"
    );
    alertDiv.role = "alert";
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      `;
  
    // Append alert to content
    contentDiv.appendChild(alertDiv);
  
    // Append content to column
    colDiv.appendChild(contentDiv);
  
    // Append column to row
    rowDiv.appendChild(colDiv);
  
    // Append row to container
    containerDiv.appendChild(rowDiv);
  
    // Get the second child of the body (could be null if body has less than two children)
    const secondChild = document.body.children[0];
  
    // Insert the container after the second child of body
    if (secondChild) {
      document.body.insertBefore(containerDiv, secondChild.nextSibling);
    } else {
      document.body.prepend(containerDiv);
    }
  
    // Function to remove the alert div after transition ends
    const removeDiv = () => {
      containerDiv.remove(); // Remove the containerDiv after transition ends
    };
  
    // Optionally, remove the message after a few seconds
    if (timeout)
      setTimeout(removeDiv, 4000);
  
    // Add an event listener to the close button to remove the entire div
    const closeButton = alertDiv.querySelector('button.close');
    closeButton.addEventListener('click', removeDiv);
  }

  if (typeof window !== 'undefined') {
    window.addMessage = addMessage;
  }