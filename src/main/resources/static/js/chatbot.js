window.onload = function () {
    loadParentMenu();
};

function addBotMsg(text) {
    const chatBody = document.getElementById('chatBody');

    const botRow = document.createElement('div');
    botRow.className = 'bot-row';

    const botIcon = document.createElement('img');
    botIcon.className = 'bot-icon';
    botIcon.src = '/images/bot.png';

    const div = document.createElement('div');
    div.className = 'bot-msg';
    div.innerText = text;

    botRow.appendChild(botIcon);
    botRow.appendChild(div);
    chatBody.appendChild(botRow);

    chatBody.scrollTo({
        top: chatBody.scrollHeight,
        behavior: 'smooth'
    });
}

function addUserMsg(text) {
    const chatBody = document.getElementById('chatBody');

    const div = document.createElement('div');
    div.className = 'user-msg';
    div.innerText = text;

    chatBody.appendChild(div);

    chatBody.scrollTo({
        top: chatBody.scrollHeight,
        behavior: 'smooth'
    });
}

function removeMenu() {
    const oldMenu = document.querySelector('.quick-menu');

    if (oldMenu != null) {
        oldMenu.remove();
    }
}

function resetChatbot() {
    const chatBody = document.getElementById('chatBody');

    chatBody.innerHTML = `
        <div class="bot-row">
            <img src="/images/bot.png" class="bot-icon">
            <div class="bot-msg">
                안녕하세요! 오늘 뭐 먹지? <br/>
                고객지원 챗봇입니다 <br/>
                궁금한 메뉴를 선택해 주세요.  
            </div>
        </div>
    `;

    loadParentMenu();
}

function loadParentMenu() {
    const chatBody = document.getElementById('chatBody');

    removeMenu();

    const parentMenu = document.createElement('div');
    parentMenu.className = 'quick-menu';
    parentMenu.id = 'parentMenu';
    chatBody.appendChild(parentMenu);

    fetch('/chatbot/parent')
        .then(res => res.json())
        .then(data => {
            data.forEach(item => {
                const btn = document.createElement('button');

                btn.type = 'button';
                btn.innerText = item.question;

                btn.onclick = function () {
                    loadSubMenu(item.id, item.question);
                };

                parentMenu.appendChild(btn);
            });

            chatBody.scrollTo({
                top: chatBody.scrollHeight,
                behavior: 'smooth'
            });
        });
}

function loadSubMenu(id, question) {
    removeMenu();

    addUserMsg(question);
    addBotMsg('궁금한 항목을 선택해주세요.');

    const chatBody = document.getElementById('chatBody');

    const subMenu = document.createElement('div');
    subMenu.className = 'quick-menu';
    subMenu.id = 'subMenu';
    chatBody.appendChild(subMenu);

    fetch('/chatbot/sub?id=' + id)
        .then(res => res.json())
        .then(data => {
            data.forEach(item => {
                const btn = document.createElement('button');

                btn.type = 'button';
                btn.innerText = item.question;

                btn.onclick = function () {
                    removeMenu();

                    addUserMsg(item.question);

                    if (item.question === '관리자에게 문의하기') {
                        location.href = '/inquiry';
                        return;
                    }

                    if (item.answer != null && item.answer !== '') {
                        addBotMsg(item.answer);
                        addBotMsg('다른 궁금한 점이 있으신가요?');
                        loadParentMenu();
                    }
                };

                subMenu.appendChild(btn);
            });

            const backBtn = document.createElement('button');
            backBtn.type = 'button';
            backBtn.className = 'back-btn';
            backBtn.innerText = '뒤로가기';

            backBtn.onclick = function () {
                removeMenu();
                loadParentMenu();
            };

            subMenu.appendChild(backBtn);

            chatBody.scrollTo({
                top: chatBody.scrollHeight,
                behavior: 'smooth'
            });
        });
}

function openChatbot() {
    const area = document.getElementById('chatbotWrap');
    if (area.style.display === 'block') {
        area.style.display = 'none';
        resetChatbot();
    } else {
        area.style.display = 'block';
    }
}


function closeChatbot() {
    document.getElementById('chatbotWrap').style.display = 'none';
    resetChatbot();
}