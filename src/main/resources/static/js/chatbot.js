// 페이지 로딩이 끝나면 챗봇의 상위 메뉴를 불러옴
window.onload = function () {
    loadParentMenu();
};

// 챗봇 답변 메시지를 화면에 추가
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

// 사용자가 선택한 질문을 화면에 추가
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
// 기존에 출력된 선택 메뉴를 제거
function removeMenu() {
    const oldMenu = document.querySelector('.quick-menu');

    if (oldMenu != null) {
        oldMenu.remove();
    }
}

// 챗봇 대화 내용을 처음 상태로 초기화
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

    // 초기화 후 상위 메뉴 다시 불러오기
    loadParentMenu();
}

// 서버에서 챗봇의 상위 질문 목록을 불러오는 함수
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

                // 상위 질문 클릭 시 해당 질문의 하위 메뉴 불러오기
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

// 선택한 상위 질문에 해당하는 하위 질문 목록 호출
function loadSubMenu(id, question) {
    removeMenu();

    // 사용자가 선택한 상위 질문과 안내 메시지 출력
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

                    // 사용자가 선택한 하위 질문 출력
                    addUserMsg(item.question);

                    // 관리자 문의 선택 시 문의하기 페이지로 이동
                    if (item.question === '관리자에게 문의하기') {
                        location.href = '/inquiry';
                        return;
                    }

                    // 답변이 존재하면 챗봇 메시지로 출력
                    if (item.answer != null && item.answer !== '') {
                        addBotMsg(item.answer);
                        addBotMsg('다른 궁금한 점이 있으신가요?');
                        loadParentMenu();
                    }
                };

                subMenu.appendChild(btn);
            });

            // 이전 단계인 상위 메뉴로 돌아가는 버튼
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
// 챗봇 창을 열거나 닫는 함수
function openChatbot() {
    const area = document.getElementById('chatbotWrap');
    if (area.style.display === 'block') {
        area.style.display = 'none';
        // 닫을 때 챗봇 대화 내용 초기화
        resetChatbot();
    } else {
        area.style.display = 'block';
    }
}

// 닫기 버튼 클릭 시 챗봇을 숨기고 초기화
function closeChatbot() {
    document.getElementById('chatbotWrap').style.display = 'none';
    resetChatbot();
}