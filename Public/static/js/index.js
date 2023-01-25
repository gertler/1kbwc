var canvas;
const strokeWidths = [2, 6, 10, 14];

function toggleFreeDraw() {
    currMode = canvas.isDrawingMode;
    canvas.isDrawingMode = !currMode;
    console.log("Test");
}

function toggleStrokeWidth(width) {
    const brush = canvas.freeDrawingBrush;
    brush.width = width;
}

function initButtons() {
    const cvs1 = document.getElementById('stroke1');
    const cvs2 = document.getElementById('stroke2');
    const cvs3 = document.getElementById('stroke3');
    const cvs4 = document.getElementById('stroke4');
    drawStaticBrushCircle(cvs1, strokeWidths[0]);
    drawStaticBrushCircle(cvs2, strokeWidths[1]);
    drawStaticBrushCircle(cvs3, strokeWidths[2]);
    drawStaticBrushCircle(cvs4, strokeWidths[3]);
    
    const btn1 = document.getElementById('toggleStroke1');
    const btn2 = document.getElementById('toggleStroke2');
    const btn3 = document.getElementById('toggleStroke3');
    const btn4 = document.getElementById('toggleStroke4');
    btn1.addEventListener('click', function() { toggleStrokeWidth(strokeWidths[0]); });
    btn2.addEventListener('click', function() { toggleStrokeWidth(strokeWidths[1]); });
    btn3.addEventListener('click', function() { toggleStrokeWidth(strokeWidths[2]); });
    btn4.addEventListener('click', function() { toggleStrokeWidth(strokeWidths[3]); });
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

    var rect = new fabric.Rect({
      top : 100,
      left : 100,
      width : 60,
      height : 70,
      fill : 'red'
    });

    canvas.add(rect);
    
    canvas.backgroundColor = 'rgb(255,255,255)'
    canvas.isDrawingMode = true;
    initButtons();
    canvas.freeDrawingBrush.width = strokeWidths[0];
    initSubmitButton();
}

window.onload = init;
