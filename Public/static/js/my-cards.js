var table;

function deleteCard(id, idx) {
    console.log("Deleting " + id + " at row " + idx);

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        // Ignore state changes except final one (0-4, 4 is DONE state)
        if (this.readyState != 4) {
            return;
        }
        
        // Output to window whether upload succeeded
        if (Math.floor(this.status / 100) == 2) {
            window.alert("Success!");
            table.deleteRow(idx);
        } else {
            console.log(this.responseText);
            window.alert("Failed to delete card!");
        }
    };
    xhttp.open("DELETE", "/cards/" + id, true);
    xhttp.send();
}

function confirmDeleteCard(event) {
    // .parentElement.parentElement.getAttribute("name")
    const elem = event.target.parentElement;
    const parent = elem.parentElement;
    if (parent.nodeName != "TR") {
        return;
    }

    const id = parent.getAttribute("name");
    // Grab index of row
    var idx = 0;
    var cardRows = table.getElementsByTagName("TR");
    for (; idx < cardRows.length; idx++) {
        if (cardRows[idx].getAttribute("name") == id) { break; }
    }

    _toggleConfirm(event.target, false);
    deleteCard(id, idx);
    // TODO: We don't want to reload every time
    // Instead, we will manually delete the row on client side
    // If deletion fails, don't delete row, but reset confirm text
}

function _toggleConfirm(obj, enabled) {
    const elem = obj.parentElement;
    const prompt = "Click here to confirm deletion &rarr; ";
    const pTag = elem.getElementsByClassName("confirm-deletion-text")[0];

    pTag.innerHTML = enabled ? prompt : "";
    if (enabled) {
        obj.removeEventListener('click', addConfirm);
        obj.addEventListener('click', confirmDeleteCard);
    } else {
        obj.addEventListener('click', addConfirm);
        obj.removeEventListener('click', confirmDeleteCard);
    }
}

function addConfirm(event) {
    _toggleConfirm(event.target, true);
}

function init() {
    table = document.getElementById("my-cards-table");
    const dButtons = document.getElementsByClassName("delete-button");
    for (button of dButtons) {
        button.addEventListener('click', addConfirm);
    }
}

window.onload = init;