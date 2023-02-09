var signInModal;
var openSignInButton;

var signUpModal;
var openSignUpButton;

function initSignin() {
    openSignInButton = document.getElementById("open-sign-in-button");
    signInModal = new Modal("modal-sign-in", "Sign In", openSignInButton);
}

function initSignup() {
    openSignUpButton = document.getElementById("open-sign-up-button");
    signUpModal = new Modal("modal-sign-up", "Sign Up", openSignUpButton);
}