<%@ page contentType="text/html;charset=UTF-8" %>

    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>게시글 작성</title>

        <link rel="stylesheet" href="/css/main.css">
        <link rel="stylesheet" href="/css/board_update.css">
        <link rel="stylesheet" href="/css/chatbot.css">

        <script src="/js/chatbot.js"></script>

    </head>

    <body>
        <jsp:include page="/WEB-INF/views/common/navibar.jsp">
            <jsp:param name="currentMenu" value="recipe" />
        </jsp:include>

        <div class="update-container">

            <h2>오늘은 어떤 레시피를 도전해 보셨나요?</h2>

            <form action="/community_write.do" method="post">

                <div class="form-group">

                    <label>제목</label>

                    <input type="text" name="title" required>

                </div>

                <div class="form-group">

                    <label>내용</label>

                    <textarea name="content" required></textarea>

                </div>

                <div class="btn-area">

                    <input type="button" value="취소" class="btn-cancel" onclick="location.href='/list.do'">

                    <input type="submit" value="등록" class="btn-submit">

                </div>

            </form>

        </div>

        <%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="/css/chatbot.css">

        <script src="/js/chatbot.js"></script>
    </head>
    <body>
        <footer>
        <div class="footer-container">
            
            <!-- [왼쪽 영역] 고객센터 (원본 태그 및 속성 유지) -->
            <div class="cs-section">
                <h3>고객센터</h3>
                <div class="cs-buttons">
                    <div class="cs-btn" onClick="location.href='/hidden.do'">📞 1833-8307</div>
                    <div class="cs-btn" onclick="location.href='/inquiry'">💬 1:1문의하기</div>
                </div>
                <div class="hours-info">
                    <p><strong>운영시간</strong></p>
                    <p>전화문의 - 10:00 ~ 12:00, 13:00 ~ 17:00 / 주말·공휴일 휴무</p>
                    <p>1:1 문의 - 09:00 ~ 12:00, 13:00 ~ 17:30 / 주말·공휴일 휴무</p>
                </div>
            </div>

            <!-- ⭐ [오른쪽 영역] 기존 링크/텍스트 유지한 채 통째로 좌우 정렬용 블록으로 묶음 -->
            <div class="footer-right-block">
                
                <!-- 상단 링크 바 (내부 링크 수정 없음) -->
                <div class="footer-nav-bar">
                    <div class="nav-links">
                        <a href="/terms.do"><strong>이용약관</strong></a>
                        <a href="/privacy.do"><strong>개인정보처리방침</strong></a>
                        <a href="/notice.do">공지사항</a>
                        <a href="javascript:void(0);" onclick="openChatbot()">자주묻는질문</a>
                    </div>
                </div>

                <!-- 하단 회사 정보 (내부 텍스트 및 태그 수정 없음) -->
                <div class="company-info">
                    <h4>주식회사 테이스티글로벌</h4>
                    <p>
                        <span>상호 : KH 개발</span>
                        <span>대표자 : 이대표</span>
                        <span>개인정보관리책임자 : 김책임</span>
                        <span>사업자 등록번호 : 111-01-31111</span>
                    </p>
                    <p>
                        <span>통신판매업 신고 : 제 2015-경기성남-1940 호</span>
                        <span>전화 : 1833-1234</span>
                        <span>팩스 : 011-1111-1111</span>
                        <span>광고/제휴 문의: kh@culture.net</span>
                    </p>
                    <p>주소 : 경기도 성남시 분당구 판교로 216길 01, kh타워 22층 2201호( 삼평동, 판교 에이치스퀘어 ) &nbsp;&nbsp; 이메일: kh@culture.net</p>
                </div>
                
            </div> <!-- /footer-right-block -->

        </div>
        </footer>

            <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

    </body>

    </html>