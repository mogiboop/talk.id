let userFilter = '';
let beginDatetimeFilter = '';
let endDatetimeFilter = '';
let typeFilter = '';
let orderFilter = 'desc';
let stateFilter = '1';
let isPlaying = false;
let offset = 10;

var port = '8000';
var protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
var chatSocket = new WebSocket(protocol + '//' + window.location.hostname + '/ws/update/');

chatSocket.onopen = function (e) {
    console.log("WebSocket connection opened");
};

chatSocket.onmessage = function (e) {
    var data = JSON.parse(e.data);
    if(data.type === "send_update"){
        addMessageToList(data.id, data.first_name, data.last_name, data.msg_type_id, data.msg_type_name, data.msg_info, data.msg_date_time, data.level);
        if(!isPlaying){
            isPlaying = true;
            const audio = new Audio('/static/sounds/mixkit-bell-notification-933.wav');
            let playCount = 0;
            const maxPlays = 3;
            if(data.msg_type_id == 1){
                function playSound() {
                    if (playCount < maxPlays) {
                        audio.play();
                        playCount++;
                        setTimeout(() => {
                            audio.pause();
                            audio.currentTime = 0;
                            if (playCount < maxPlays) {
                                playSound();
                            } else {
                                isPlaying = false;
                            }
                        }, 3000); 
                    }
                }
    
                playSound();
            }
        }
    }
    else if(data.type === "message_viewed"){
        updateMessageAsViewed(data.id);
    }
    else if(data.type === "message_state"){
        updateMessageState(data.id);
    }
};

chatSocket.onclose = function (e) {
    console.error("Chat socket closed unexpectedly");
};

chatSocket.onerror = function (e) {
    console.error("WebSocket error: ", e);
};

function updateMessageAsViewed(id) {
    const messageElement = document.querySelector(`.list-group-item[data-id="${id}"]`);
    if (messageElement && stateFilter == '1') {
        messageElement.classList.remove("blink");
    }
}

function updateMessageState(id) {
    const messageElement = document.querySelector(`.list-group-item[data-id="${id}"]`);
    if (messageElement ) {
        messageElement.remove();
    }
}

function restartBlinkingAnimation() {
    const blinkingElements = document.querySelectorAll('.blink');
    blinkingElements.forEach(element => {
        element.style.animation = 'none';
        element.offsetHeight; 
        element.style.animation = null;
    });
}

function addMessageToList(id, first_name, last_name, msg_type_id, msg_type_name, msg_info, msg_date_time, level){
    var noMessagesElement = document.getElementById('no-messages');
    noMessagesElement.style.display = "none";
    if(userFilter == '' && beginDatetimeFilter == '' && endDatetimeFilter == '' && typeFilter == '' && orderFilter == 'desc' && stateFilter == '1'){
        var messageList = document.getElementById('message-list');
        const listItem = document.createElement('li');
        listItem.classList.add('list-group-item');
        listItem.classList.add('blink');
        listItem.dataset.user = first_name +" "+last_name;
        listItem.dataset.msg_type_name = msg_type_name;
        listItem.dataset.id = id;
        listItem.dataset.info = msg_info;
        listItem.dataset.type = msg_type_id;
        listItem.dataset.datetime = msg_date_time;
        if(level != null && level != ""){
            listItem.dataset.level = level;
        }

        listItem.innerHTML = `
            <div class="message-info">${msg_info}</div>
            <div class="message-datetime">${msg_date_time}</div>
        `;
        if (messageList.firstChild) {
            messageList.insertBefore(listItem, messageList.firstChild);
        } else {
            messageList.appendChild(listItem); 
        }
        restartBlinkingAnimation();  
    }
}

document.addEventListener('DOMContentLoaded', () => {

    const solution = document.getElementById('solution');
    solution.addEventListener('input', () => {
        solution.style.height = 'auto';
        solution.style.height = `${solution.scrollHeight}px`;
    });
    
    let currentImage = null; 
    var loadMoreButton = document.getElementById('load-more');
    var messageList = document.getElementById('message-list');
    let circlesData = [];
    
    if(messageList){
        
        document.getElementById('message-list').addEventListener('click', event => {
            circlesData = [];
            document.getElementById('solution-title').style.display = 'none';
            document.getElementById('solution-list').innerHTML = '';
            document.getElementById('solution').value = '';
            const listItem = event.target.closest('.list-group-item');
            if (!listItem) return; 
            const username = listItem.getAttribute('data-user');
            const msgTypeName = listItem.getAttribute('data-msg_type_name');
            const messageID = listItem.getAttribute('data-id');
            const info = listItem.getAttribute('data-info');
            const datetime = listItem.getAttribute('data-datetime');
            const type = listItem.getAttribute('data-type');

            if(messageID === document.getElementById('message-details').getAttribute('data-id')){
                document.getElementById('message-details').style.display = 'none';
                document.getElementById('message-details').setAttribute('data-id', '');
                listItem.classList.remove('selected');
            }
            else{
                // Remove the 'selected' class from all list items
                document.querySelectorAll('#message-list .list-group-item').forEach(item => {
                    item.classList.remove('selected');
                });
    
                // Add the 'selected' class to the clicked list item
                listItem.classList.add('selected');
                document.getElementById('message-details').setAttribute('data-id', messageID);
                document.getElementById('details-info').textContent = `${msgTypeName}: ${info}`;
                document.getElementById('details-user').textContent = "Pacient: " + username;
                document.getElementById('details-datetime').textContent = datetime;
                document.getElementById('details-image').src = "../../static/images/Muscles_front_and_back.svg";

                // Clear canvas before loading new circles
                clearCanvas();

                if (type == 3) {
                    if(listItem.hasAttribute('data-level')){
                        const level = listItem.getAttribute('data-level');
                        document.getElementById('details-level').style.display = "block";
                        document.getElementById('details-level').textContent = "Level: " + level;
                    }
                    else{
                        document.getElementById('details-level').style.display = "none";
                    }
                    
                    document.getElementById('details-image').onload = function() {
                        currentImage = this; 
                        const canvas = document.getElementById('canvas');
                        const ctx = canvas.getContext('2d');
                        
                        canvas.width = this.width;
                        canvas.height = this.height;

                        fetch(`/app_comm_api/getMsgsCoord/${messageID}/`, {
                            method: "GET",
                            headers: {
                                "Content-Type": "application/json",
                                "X-CSRFToken": getCookie('csrftoken'),
                            },
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success && Array.isArray(data.data)) {
                                circlesData = data.data; 
                                redrawCircles(); 
                            } else {
                                console.error("Failed to get pain zones");
                            }
                        })
                        .catch(error => console.error("Error:", error));
                    };
                } else {
                    document.getElementById('details-level').style.display = "none";
                }

                document.getElementById('message-details').style.display = 'block';

                if (listItem.classList.contains('blink')) {
                    fetch(`/app_comm_api/updateMsgViewed/${messageID}/`, {
                        method: "PATCH",
                        headers: {
                            "Content-Type": "application/json",
                            "X-CSRFToken": getCookie('csrftoken'),
                        },
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            listItem.classList.remove("blink");
                        } else {
                            console.error("Failed to update message visibility");
                        }
                    })
                    .catch(error => console.error("Error:", error));
                }

                if(stateFilter == '2'){
                    fetch(`/app_comm_api/getMsgsSol/${messageID}/`, {
                        method: "GET",
                        headers: {
                            "Content-Type": "application/json",
                            "X-CSRFToken": getCookie('csrftoken'),
                        },
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success && Array.isArray(data.data)) {
                            const solutionList = document.getElementById('solution-list');
                            if(data.data.length>0){
                                data.data.forEach(solution => {
                                    const listItem = document.createElement('li');
                                    listItem.className = 'list-group-item';
                                    listItem.innerHTML = `<strong>${solution.username}</strong>: ${solution.message_solution}`;
                                    solutionList.appendChild(listItem);
                                });
                                document.getElementById('solution-title').style.display = 'block';
                            }
                        } else {
                            console.error("Failed to get pain zones");
                        }
                    })
                    .catch(error => console.error("Error:", error));
                }
            }
        });
    }
    
    document.getElementById('filter-button').addEventListener('click', () => {
        document.getElementById('message-details').style.display = 'none';
        document.getElementById('message-details').setAttribute('data-id', '');
        document.querySelectorAll('#message-list .list-group-item').forEach(item => {
            item.classList.remove('selected');
        });

        
        if (
            userFilter == document.getElementById('user-filter').value.trim() && beginDatetimeFilter == document.getElementById('begin-datetime-filter').value.trim()
            && endDatetimeFilter == document.getElementById('end-datetime-filter').value.trim() && typeFilter == document.getElementById('type-filter').value.trim()
            &&orderFilter == document.getElementById('order-filter').value.trim() && stateFilter == document.getElementById('state-filter').value.trim()
        ) {
            return;
        }

        userFilter = document.getElementById('user-filter').value.trim();
        beginDatetimeFilter = document.getElementById('begin-datetime-filter').value.trim();
        endDatetimeFilter = document.getElementById('end-datetime-filter').value.trim();
        typeFilter = document.getElementById('type-filter').value.trim();
        orderFilter = document.getElementById('order-filter').value.trim();
        stateFilter = document.getElementById('state-filter').value.trim();

        getMessagesWithFilters();
        
    });

    
    document.getElementById('reset-button').addEventListener('click', () => {
        document.getElementById('message-details').style.display = 'none';
        document.getElementById('message-details').setAttribute('data-id', '');
        document.querySelectorAll('#message-list .list-group-item').forEach(item => {
            item.classList.remove('selected');
        });
        const endDatetimeInput = document.getElementById('end-datetime-filter');
        endDatetimeInput.value = '';
        endDatetimeInput.disabled = true;
        endDatetimeInput.removeAttribute('min');

        userFilter = '';
        beginDatetimeFilter = '';
        endDatetimeFilter = '';
        typeFilter = '';
        orderFilter = 'desc';
        stateFilter = '1'

        document.getElementById('user-filter').value = userFilter;
        document.getElementById('begin-datetime-filter').value = beginDatetimeFilter;
        document.getElementById('end-datetime-filter').value = endDatetimeFilter;
        document.getElementById('type-filter').value = typeFilter;
        document.getElementById('order-filter').value = orderFilter;
        document.getElementById('state-filter').value = stateFilter;

        getMessagesWithFilters();

    });

    document.getElementById('close-button').addEventListener('click', () => {
        document.getElementById('message-details').style.display = 'none';
        document.getElementById('message-details').setAttribute('data-id', '');
        document.getElementById('solution').value = '';
        document.querySelectorAll('#message-list .list-group-item').forEach(item => {
            item.classList.remove('selected');
        });
    });

    
    document.getElementById('done-button').addEventListener('click', () => {
        document.getElementById('message-details').style.display = 'none';
        document.querySelectorAll('#message-list .list-group-item').forEach(item => {
            item.classList.remove('selected');
        });

        const messageID = document.getElementById('message-details').getAttribute('data-id');
        var solution = $("#solution").val();
        fetch(`/app_comm_api/updateMsgState/${messageID}/`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': getCookie('csrftoken') 
            },
            body: JSON.stringify({ solution: solution}),
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            else{
                if(messageList){
                    const idString = messageID.toString();
                    item = document.querySelector(`#message-list .list-group-item[data-id="${idString}"]`);
                    if(item && stateFilter=='1'){
                        item.remove();
                    }
                }
            }
        })
        .catch(error => {
            console.error('Error activating user:', error);
        });
        document.getElementById('message-details').setAttribute('data-id', '');
        document.getElementById('solution').value = '';
    });

    document.getElementById('begin-datetime-filter').addEventListener('input', function() {
        const beginDatetime = this.value.trim();
        const endDatetimeInput = document.getElementById('end-datetime-filter');

        if (beginDatetime) {
            endDatetimeInput.disabled = false;
            endDatetimeInput.min = beginDatetime;
        } else {
            endDatetimeInput.value = '';
            endDatetimeInput.disabled = true;
            endDatetimeInput.removeAttribute('min');
        }
    });

    if (loadMoreButton) {
        document.getElementById('load-more').addEventListener('click', function() {

            const params = new URLSearchParams();
            params.append('offset', offset)
            if (userFilter) params.append('user', userFilter);
            if (beginDatetimeFilter) params.append('begin_datetime', beginDatetimeFilter);
            if (endDatetimeFilter) params.append('end_datetime', endDatetimeFilter);
            if (typeFilter) params.append('message_type', typeFilter);
            if (orderFilter) params.append('order', orderFilter);
            if (stateFilter) params.append('state', stateFilter);

            fetch(`/app_comm_api/loadMoreMsgs?${params.toString()}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const messageList = document.getElementById('message-list');
                        const button = messageList.querySelector('#load-more');
                        if (data.data.length > 0) {
                            data.data.slice(0, 10).forEach(msg => {
                                const listItem = document.createElement('li');
                                listItem.classList.add('list-group-item');
                                if (!msg.viewed) listItem.classList.add('blink');
                                listItem.dataset.user = `${msg.user.first_name} ${msg.user.last_name}`;
                                listItem.dataset.msg_type_name = msg.message_type.message_type_name;
                                listItem.dataset.id = msg.id;
                                listItem.dataset.info = msg.message_info;
                                listItem.dataset.type = msg.message_type.id;
                                listItem.dataset.datetime = msg.formatted_date_time;

                                listItem.innerHTML = `
                                    <div class="message-info">${msg.message_info}</div>
                                    <div class="message-datetime">${msg.formatted_date_time}</div>
                                `;
                                messageList.insertBefore(listItem, button);
                            });
                            if(data.data.length<11){
                                hideLoadMore();
                            }
                            else{
                                showLoadMore();
                                offset += data.data.length-1;

                                // Restart the blinking animation
                                restartBlinkingAnimation();
                            }
                        }
                    }
                })
                .catch(error => console.error('Error loading more messages:', error));
        });
    }
    

    function getMessagesWithFilters(){
        const params = new URLSearchParams();
        if (userFilter) params.append('user', userFilter);
        if (beginDatetimeFilter) params.append('begin_datetime', beginDatetimeFilter);
        if (endDatetimeFilter) params.append('end_datetime', endDatetimeFilter);
        if (typeFilter) params.append('message_type', typeFilter);
        if (orderFilter) params.append('order', orderFilter);
        if (stateFilter) params.append('state', stateFilter);

        fetch(`/app_comm_api/getMsgsFilter?${params.toString()}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
                "X-CSRFToken": getCookie('csrftoken'),
            },
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const messageList = document.getElementById('message-list');
                const button = messageList.querySelector('#load-more');
                const messages = messageList.querySelectorAll('li.list-group-item');
                messages.forEach(message => {
                    message.remove();
                });
                if (data.data.length > 0) {
                    data.data.slice(0, 10).forEach(msg => {
                        const listItem = document.createElement('li');
                        listItem.classList.add('list-group-item');
                        if (!msg.viewed) listItem.classList.add('blink');
                        listItem.dataset.user = `${msg.user.first_name} ${msg.user.last_name}`;
                        listItem.dataset.msg_type_name = msg.message_type.message_type_name;
                        listItem.dataset.id = msg.id;
                        listItem.dataset.info = msg.message_info;
                        listItem.dataset.type = msg.message_type.id;
                        listItem.dataset.datetime = msg.formatted_date_time;

                        listItem.innerHTML = `
                            <div class="message-info">${msg.message_info}</div>
                            <div class="message-datetime">${msg.formatted_date_time}</div>
                        `;
                        messageList.insertBefore(listItem, button);
                    });
                    
                    if(data.data.length < 11){
                        hideLoadMore();
                    }
                    else{
                        showLoadMore();
                    }
                    document.getElementById('no-messages').style.display = 'none';
                } else {
                    button.style.display = 'none';
                    document.getElementById('no-messages').style.display = 'block';
                }
            } else {
                console.error("Failed to update message visibility");
            }
        })
        .catch(error => console.error('Error fetching messages:', error));
    }

    function redrawCircles() {
        if (!currentImage) return;
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        
        canvas.width = currentImage.width;
        canvas.height = currentImage.height;
        
        clearCanvas();
        
        circlesData.forEach(coord => {
            const scaleX = canvas.width / coord.imageWidth;
            const scaleY = canvas.height / coord.imageHeight;
            const scaleR = (scaleX + scaleY) / 2;
            drawCircle(ctx, coord.x * scaleX, coord.y * scaleY, coord.radius * scaleR, coord.color.replace(/#(..)(......)/, '#$2$1'));
        });
    }

    function drawCircle(ctx, x, y, radius, color) {
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, Math.PI * 2);
        ctx.lineWidth = 2;
        ctx.strokeStyle = color;
        ctx.stroke();
    }

    function clearCanvas() {
        document.getElementById('details-image').onload = function() {
            if (currentImage) {
                const canvas = document.getElementById('canvas');
                const ctx = canvas.getContext('2d');
                canvas.width = this.width;
                canvas.height = this.height;
                ctx.clearRect(0, 0, canvas.width, canvas.height);
            }
        }
    }

    function hideLoadMore(){
        document.getElementById('load-more').style.display = "none";
    }

    function showLoadMore(){
        document.getElementById('load-more').style.display = "block";
    }

    // Add event listener to handle window resize
    window.addEventListener('resize', redrawCircles);
});


function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            // Check if the cookie name matches the format we expect (name=value)
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
  }