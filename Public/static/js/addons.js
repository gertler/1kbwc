const strokeWidths = [2, 6, 10, 14, 20];

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

function initAddons() {
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
}