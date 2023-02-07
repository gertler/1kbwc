var signInModal;
var openSignInButton;

function initLogin() {
    openSignInButton = document.getElementById("open-sign-in-button");
    signInModal = new Modal("modal-sign-in", "Sign In", openSignInButton);
}
