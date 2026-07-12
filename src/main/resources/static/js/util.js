function getActiveRoot(root) {
    return root || document.querySelector(".review-card.open") || document;
}

function setText(id, value, rootElement) {
    const root = getActiveRoot(rootElement);
    const target = root.querySelector("#model-" + id);

    if (!target) {
        return;
    }

    if (value == "public") {
        target.textContent = "public";
    } else if (value == "private") {
        target.textContent = "private";
    } else {
        target.textContent = value ?? "-";
    }
}

function setImg(id, src, rootElement) {
    const root = getActiveRoot(rootElement);
    const img = root.querySelector("#" + id);

    if (img) {
        img.src = src;
    }
}

function setImgs(id, imglist, rootElement) {
    const root = getActiveRoot(rootElement);
    const box = root.querySelector("#" + id);

    if (!box) {
        return;
    }

    box.innerHTML = "";

    if (!imglist || imglist.length == 0) {
        box.textContent = "-";
        return;
    }

    imglist.forEach(img => {
        box.innerHTML += `
            <img src="/upload/review/${img}"
                 class="modal-review-img"
                 onclick="openImageModal(this.src)">
        `;
    });
}

function setA(id, path, rootElement){
    const root = getActiveRoot(rootElement);
    const a = root.querySelector("#model-"+id);

    if(!a){
        return;
    }
    a.href = path ?? '#';
}

function setList( id, list){
    const target = document.getElementById("model-"+id);
    
    target.innerHTML = "";

    if(!list || list.length == 0){
        target.innerHTML = "신고내역이 없습니다.";
        return;
    }

    list.forEach(item => {
        const li = document.createElement("li");
        li.textContent = `${item.created_date}  ${item.reason}`;
        target.appendChild(li);
    })

}

