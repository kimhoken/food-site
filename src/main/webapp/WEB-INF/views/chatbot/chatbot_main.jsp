<%@ page contentType="text/html;charset=UTF-8" language="java" %>

    <!DOCTYPE html>
    <html>

    <head>
        
    </head>

    <body>

        <!-- 화면 오른쪽 아래에 고정되는 챗봇 실행 버튼 -->
        <input type="button" class="chatbot-fixed-btn" value="?" onclick="openChatbot()" />

        <div class="chatbot-wrap" id="chatbotWrap">

            <!-- 챗봇 상단 헤더 -->
            <div class="chat-header">
                <img src="/images/bot.png" class="bot-icon">
                <span>도우미봇</span>
                <button type="button" class="chat-close-btn" onclick="closeChatbot()">x</button>
            </div>

            <div class="chat-body" id="chatBody">

                <!-- 챗봇의 기본 안내 메시지 -->
                <div class="bot-row">
                    <img src="/images/bot.png" class="bot-icon">
                    <div class="bot-msg">
                        안녕하세요! 오늘 뭐 먹지? <br/>
                        고객지원 챗봇입니다 <br/>
                        궁금한 메뉴를 선택해 주세요.    
                    </div>
                </div>

                <!-- 상위 카테고리 버튼이 동적으로 추가되는 영역 -->
                <div class="quick-menu" id="parentMenu"></div>

            </div>

        </div>

    </body>

    </html>