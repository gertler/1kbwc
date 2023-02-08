class Modal {
    constructor(divId, title, openButton) {
        // Create base elements; grab original modal text
        this.div = document.getElementById(divId);
        this.contents = this.div.innerHTML;
        this.div.innerHTML = "";
        this.title = title;
        var content = document.createElement("div");
        var header = document.createElement("div");
        var body = document.createElement("div");
        var closeButton = document.createElement("span");

        // Set classes
        this.div.className = "modal";
        content.className = "modal-content";
        header.className = "modal-header";
        body.className = "modal-body";
        closeButton.className = "modal-close";

        // Set header
        header.appendChild(closeButton);
        closeButton.innerHTML = "&times;"
        var titleElem = document.createElement("h2");
        titleElem.innerHTML = this.title;
        header.appendChild(titleElem);

        // Set body
        body.innerHTML = this.contents;

        const _div = this.div;
        // When user clicks on close button, close modal
        closeButton.onclick = function() {
            _div.style.display = "none";
        };
        // When user clicks outside of modal, close modal
        window.onclick = function(event) {
            if (event.target == _div) {
                _div.style.display = "none";
            }
        };
        // When user clicks open button, display modal
        openButton.onclick = function () {
            _div.style.display = "block";
        };

        // Add header and body to content; add content to main div
        content.appendChild(header);
        content.appendChild(body);
        this.div.appendChild(content);
        
    }

    dismiss() {
        this.div.style.display = "none";
    }

    display() {
        this.div.style.display = "block";
    }
}