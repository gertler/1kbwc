function toggleConfirm(event) {
    const elem = event.target.parentElement;
    const prompt = "Click here to confirm deletion &rarr; ";
    const pTag = elem.getElementsByClassName("confirm-deletion-text")[0];
    pTag.innerHTML = prompt;
    event.target.removeEventListener('click', toggleConfirm);
}

function init() {
    const dButtons = document.getElementsByClassName("delete-button");
    for (button of dButtons) {
        button.addEventListener('click', toggleConfirm);
    }
}

window.onload = init;