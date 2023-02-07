var canvas;
const titleTextTop = 30;
const rulesTextTop = 450;
var titleText;
var rulesText;
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

function initTitleText() {
    const width = canvas.width - 8;
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
        titleText.width = width;
        titleText.bringToFront();
        titleText.centerH();
        titleText.setCoords();
    });
}

function initRulesText() {
    const width = canvas.width - 16;
    rulesText = new fabric.Textbox("+100 points", { 
        top: rulesTextTop,
        textAlign: "center", 
        width: width,
        fontFamily: "Arial",
        fontSize: 48,
        fontStyle: "bold"
    });
    canvas.add(rulesText);
    rulesText.centerH();
    rulesText.setCoords();
    rulesText.selectable = false;

    const rulesInput = document.getElementById("rules-input");
    rulesInput.addEventListener('input', (e) => {
        const text = e.target.value;

        // Dynamic font size
        if (text.length < 16) {
            rulesText.fontSize = 48;
            rulesText.top = rulesTextTop;
        } else if (text.length < 60) {
            rulesText.fontSize = 38;
            rulesText.top = rulesTextTop - 50;
        } else if (text.length < 160) {
            rulesText.fontSize = 28;
            rulesText.top = rulesTextTop - 100;
        } else {
            rulesText.fontSize = 18;
            rulesText.top = rulesTextTop - 125;
        }

        rulesText.text = text;
        rulesText.width = width;
        rulesText.bringToFront();
        rulesText.centerH();
        rulesText.setCoords();
    });
}

function init() {
    // const cvs = document.getElementById('canvas');
    canvas = new fabric.Canvas('canvas');
    canvas.renderAll();

    toggleFreeDrawButton = document.getElementById("toggle-free-draw");
    toggleFreeDraw();
    
    canvas.backgroundColor = 'rgb(255,255,255)'
    initSubmit(canvas);
    initAddons(canvas);
    initTitleText();
    initRulesText();
}

window.onload = init;
