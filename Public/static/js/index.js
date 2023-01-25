var canvas;

function toggleFreeDraw() {
    currMode = canvas.isDrawingMode;
    canvas.isDrawingMode = !currMode;
    console.log("Test");
}

function toggleStrokeWidth(width) {
    const brush = canvas.freeDrawingBrush;
    brush.width = width;
}

function initSubmitButton() {
    const btn = document.getElementById('upload-button');
    btn.addEventListener('click', function() {
        const cvs = document.getElementById('canvas');
        submitCard(cvs);
    });
}

function init() {
    canvas = new fabric.Canvas('canvas');
    const cvs = document.getElementById('canvas');
    cvs.width = 409;
    cvs.height = 585;
    var text = new fabric.Text('hello world', { left: 100, top: 100 });
    canvas.add(text);
    
    canvas.backgroundColor = 'rgb(255,255,255)'
    canvas.isDrawingMode = true;
    canvas.freeDrawingBrush.width = strokeWidths[0];
    initSubmit();
    initAddons();
}

window.onload = init;
