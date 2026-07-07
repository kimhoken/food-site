<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시글 수정</title>

<link rel="stylesheet" href="/css/main.css">
<link rel="stylesheet" href="/css/board_update.css">
<link rel="stylesheet" href="/css/chatbot.css">

<script src="/js/chatbot.js"></script>

</head>
<body>

<div class="update-container">

    <h2>게시글 수정</h2>

    <form action="/update.do" method="post">

        <input type="hidden"
               name="board_id"
               value="${board.board_id}">

        <div class="form-group">

            <label>제목</label>

            <input type="text"
                   name="title"
                   value="${board.title}"
                   required>

        </div>

        <div class="form-group">

            <label>내용</label>

            <textarea name="content" required>${board.content}</textarea>

        </div>

        <div class="btn-area">

            <input type="button"
                   value="취소"
                   class="btn-cancel"
                   onclick="history.back()">

            <input type="submit"
                   value="수정완료"
                   class="btn-submit">

        </div>

    </form>

    <footer>
                <div class="footer-container">
                    <div class="footer-top-row">
                        <div class="cs-section">
                            <h3>고객센터</h3>
                            <div class="cs-buttons">
                                <div class="cs-btn" onClick="location.href='/hidden.do'">📞 1833-8307</div>
                                <div class="cs-btn">💬 1:1문의하기</div>
                            </div>
                            <div class="hours-info">
                                <p><strong>운영시간</strong></p>
                                <p>전화문의 - 10:00 ~ 12:00, 13:00 ~ 17:00 / 주말·공휴일 휴무</p>
                                <p>1:1 문의 - 09:00 ~ 12:00, 13:00 ~ 17:30 / 주말·공휴일 휴무</p>
                            </div>
                        </div>
                        <div class="sns-icons">
                            <span class="sns-icon">▶</span>
                            <span class="sns-icon">★</span>
                            <span class="sns-icon">☆</span>
                            <span class="sns-icon">◆</span>
                            <span class="sns-icon">♬</span>
                        </div>
                    </div>
                </div>

                <div class="footer-nav-bar">
                    <div class="footer-container">
                        <div class="nav-links">
                            <a href="#"><strong>이용약관</strong></a>
                            <a href="#"><strong>개인정보처리방침</strong></a>
                            <a href="/notice.do">공지사항</a>
                             <a href="javascript:void(0);" onclick="openChatbot()">자주묻는질문</a>
                            <span class="partner-mail">광고/제휴 문의: kh@culture.net</span>
                        </div>
                    </div>
                </div>

                <div class="footer-container">
                    <div class="footer-bottom-row">
                        <div class="company-info">
                            <h4>주식회사 코코짱짱</h4>
                            <p>
                                <span>상호 : KH 개발</span>
                                <span>대표자 : 장승연</span>
                                <span>개인정보관리책임자 : 장승연</span>
                                <span>사업자 등록번호 : 111-01-31111</span>
                            </p>
                            <p>
                                <span>통신판매업 신고 : 제 2015-경기성남-1940 호</span>
                                <span>전화 : 1833-1234</span>
                                <span>팩스 : 031-8017-1800</span>
                            </p>
                            <p>주소 : 경기도 성남시 분당구 판교로 216길 92, kh타워 22층 2201호( 삼평동, 판교 에이치스퀘어 ) &nbsp;&nbsp; 이메일:
                                kh@culture.net</p>
                        </div>
                    </div>
                </div>
            </footer>

</div>

<jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

</body>
</html>