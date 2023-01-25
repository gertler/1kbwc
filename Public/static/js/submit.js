function submitCard(canvas) {
    const submitBtn = document.getElementById('upload-button');
    submitBtn.disabled = true;
    
    
    canvas.toBlob((blob) => {
        const title = document.getElementById('title-input').value;
        _submitCardAjax(blob, title);
    }, 'image/png');
}

function _submitCardAjax(blob, title) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState != 4) {
            return;
        }
        
        if (this.status == 200) {
            window.alert("Success!");
        } else {
            window.alert("Failure to upload image!");
        }
    };
    xhttp.open("POST", "/cards/?title=" + title, true);
    xhttp.send(blob);
}
