var titleInput;

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
        if (this.readyState != 4) {
            return;
        }
        
        if (this.status == 200) {
            window.alert("Success!");
            submitBtn.disabled = false;
        } else {
            window.alert("Failure to upload image!");
        }
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
    
    canvas.toBlob((blob) => {
        const title = document.getElementById('title-input').value;
        _submitCardAjax(blob, title, submitBtn);
    }, 'image/png');
}

function initSubmit() {
    const btn = document.getElementById('upload-button');
    btn.addEventListener('click', function() {
        const cvs = document.getElementById('canvas');
        submitCard(cvs);
    });

    titleInput = document.getElementById("title-input");
}