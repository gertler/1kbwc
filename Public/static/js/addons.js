const strokeWidths = [2, 6, 10, 14, 20];
var colorPicker1;
var colorPicker2;
var testModal;

function drawStaticBrushCircle(canvas, diameter) {
    const ctx = canvas.getContext('2d');
    const x = canvas.width / 2;
    const y = canvas.height / 2;
    const radius = diameter / 2;
    
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false);
    ctx.fillStyle = 'black';
    ctx.fill();
    ctx.stroke();
}

function toggleStrokeWidth(width) {
    const brush = canvas.freeDrawingBrush;
    brush.width = width;
}

function initColorPicker(canvas) {
    const brush = canvas.freeDrawingBrush;
    colorPicker1 = document.getElementById("color-picker-1");
    colorPicker1.addEventListener("change", (event) => {
        brush.color = event.target.value;
    });
    colorPicker2 = document.getElementById("color-picker-2");
    colorPicker2.addEventListener("change", (event) => {
        console.log("TODO: Change fill color after adding support for shapes.");
    });
}

function initAddons(canvas) {
    // Init stroke width buttons
    canvas.freeDrawingBrush.width = strokeWidths[0];
    const btns = document.getElementsByClassName("toggle-stroke-width");
    var i = 0;
    for (const btn of btns) {
        const width = strokeWidths[i];
        btn.addEventListener('click', function() { 
            toggleStrokeWidth(width); 
        });
        const cvs = btn.getElementsByClassName("stroke-width-shape")[0];
        drawStaticBrushCircle(cvs, width);
        i++;
    }

    initColorPicker(canvas);
}