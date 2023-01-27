var titleInput;

// https://stackoverflow.com/questions/12168909/blob-from-dataurl
function dataURLToBlob(dataURI) {
    // convert base64 to raw binary data held in a string
    // doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
    var byteString = atob(dataURI.split(',')[1]);

    // separate out the mime component
    var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

    // write the bytes of the string to an ArrayBuffer
    var ab = new ArrayBuffer(byteString.length);

    // create a view into the buffer
    var ia = new Uint8Array(ab);

    // set the bytes of the buffer to the correct values
    for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
    }

    // write the ArrayBuffer to a blob, and you're done
    var blob = new Blob([ab], {type: mimeString});
    return blob;
}

function validateInput() {
    const len = titleInput.value.length
    if (len < 1 || len > 32) {
        window.alert("Title must be between 1 and 32 characters long!");
        return false;
    }
    return true;
}

function _submitCardAjax(blob, title, submitBtn) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        // Ignore state changes except final one (0-4, 4 is DONE state)
        if (this.readyState != 4) {
            return;
        }

        // Stop the spinner from displaying
        const loader = document.getElementById("submit-spinner");
        loader.style.display = "none";
        
        // Output to window whether upload succeeded
        if (this.status == 200) {
            window.alert("Success!");
        } else {
            console.log(this.responseText);
            window.alert("Failure to upload image!");
        }

        // Re-enable the submit button
        submitBtn.disabled = false;
    };
    xhttp.open("POST", "/cards/?title=" + title, true);
    xhttp.send(blob);
}

function submitCard(canvas) {
    const submitBtn = document.getElementById('upload-button');
    submitBtn.disabled = true;
    
    const isValid = validateInput();
    if (!isValid) {
        submitBtn.disabled = false;
        return;
    }

    // Start spinner after validation is complete
    const loader = document.getElementById("submit-spinner");
    loader.style.display = "block";

    // canvas.enableRetinaScaling = false;
    var dataURL = canvas.toDataURL({ format: 'png', multiplier: 1 });
    // canvas.enableRetinaScaling = true;
    const blob = dataURLToBlob(dataURL);
    const title = document.getElementById('title-input').value;
    _submitCardAjax(blob, title, submitBtn);
}

function initSubmit(canvas) {
    const btn = document.getElementById('upload-button');
    btn.addEventListener('click', function() {
        submitCard(canvas);
    });

    titleInput = document.getElementById("title-input");
}