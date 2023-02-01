var signInModal;
var openSignInButton;
var signInButton;

function acquireSessionId(token) {
    const bearerHeader = "Bearer " + token;
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        // Ignore state changes except final one (0-4, 4 is DONE state)
        if (this.readyState != 4) {
            return;
        }
        
        // Output to window whether upload succeeded
        console.log(this.responseText);
        if (this.status == 200) {
            window.open("/", "_self");
        } else {
        }
    };
    xhttp.open("GET", "/users/me", true);
    xhttp.setRequestHeader("Authorization", bearerHeader);
    xhttp.send();
}

function login(username, password) {
    const basicHeader = "Basic " + btoa(username + ":" + password);

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        // Ignore state changes except final one (0-4, 4 is DONE state)
        if (this.readyState != 4) {
            return;
        }

        // Re-enable the submit button
        signInButton.disabled = false;
        signInModal.dismiss();
        
        // Output to window whether upload succeeded
        console.log(this.responseText);
        var obj = JSON.parse(this.responseText);
        if (this.status == 200) {
            acquireSessionId(obj.token);
        } else {
            window.alert(obj.reason);
        }
    };
    xhttp.open("POST", "/users/login", true);
    xhttp.setRequestHeader("Authorization", basicHeader);
    xhttp.send();
}

function initLogin() {
    openSignInButton = document.getElementById("open-sign-in-button");
    signInModal = new Modal("modal-sign-in", "Sign In", openSignInButton);
    signInButton = document.getElementById("sign-in-button");

    signInButton.addEventListener("click", function(e) {
        e.target.disabled = true;
        const username = document.getElementById("username-input").value;
        const password = document.getElementById("password-input").value;
        login(username, password);
    });
}
