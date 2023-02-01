var canvas;
const titleTextTop = 30;
var titleText;
var toggleFreeDrawButton;

function toggleFreeDraw() {
    currMode = canvas.isDrawingMode;
    canvas.isDrawingMode = !currMode;
    if (canvas.isDrawingMode) {
        toggleFreeDrawButton.textContent = "Free Draw Enabled"
    } else {
        toggleFreeDrawButton.textContent = "Free Draw Disabled"
    }
}

function setTitleTextOnCanvas(newText) {
    titleText.text
}

function initTitleText() {
    const width = canvas.width - 16;
    titleText = new fabric.Textbox("Sample Title", { 
        top: titleTextTop, 
        textAlign: "center", 
        width: width,
        fontFamily: "Impact",
        fontSize: 64
    });
    canvas.add(titleText);
    titleText.centerH();
    titleText.setCoords();
    titleText.selectable = false;

    const titleInput = document.getElementById("title-input");
    titleInput.addEventListener('input', (e) => {
        titleText.text = e.target.value;
        titleText.centerH();
        titleText.setCoords();
    });

    // titleTextbox.on("selection:cleared", (e) => {
    //     e.target.centerH();
    //     e.target.setCoords();
    // });
}

function init() {
    // const cvs = document.getElementById('canvas');
    canvas = new fabric.Canvas('canvas');
    // canvas.renderAll();
    canvas.renderAll();

    toggleFreeDrawButton = document.getElementById("toggle-free-draw");
    toggleFreeDraw();
    
    canvas.backgroundColor = 'rgb(255,255,255)'
    initSubmit(canvas);
    initAddons(canvas);
    initTitleText();
}

window.onload = init;
