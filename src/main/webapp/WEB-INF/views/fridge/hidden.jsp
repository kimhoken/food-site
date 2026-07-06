<%@ page import="java.util.Random"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        
        <style>
            /* 버튼을 담을 상자 크기 지정 */
            .spline-toggle-box {
                width: 100%;  /* 버튼 너비 (화면 보면서 원하는 대로 조절해!) */
                height: 100%;  /* 버튼 높이 */
                
                /* 필요하다면 위치 조정을 위한 속성들 추가 */
                display: inline-block;
                /* position: absolute; top: 20px; right: 20px; 이런 식으로 쓸 수도 있어 */
            }
            
            /* 3D 뷰어가 상자 크기에 딱 맞게 렌더링되도록 100%로 설정 */
            .spline-toggle-box spline-viewer {
                width: 100%;
                height: 100%;
            }
        </style>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="/css/chatbot.css" />
        <script src="/js/chatbot.js"></script>
        <script type="module" src="/js/Toggle.js"></script>
        <title>오늘 뭐먹지? - 이스터에그</title>
    </head>
    <body>
        <header>
            <div class="header-top">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/">
                        <img src="${pageContext.request.contextPath}/images/Logo.png" alt="로고">
                    </a>
                </div>

                <form action="${pageContext.request.contextPath}/search.do" method="post" class="search-bar-form">
                    <div class="search-bar">
                        <input type="text" id="mainSearch" name="search" placeholder="재료, 요리명으로 검색해보세요!">
                        <button type="submit">⌕</button>
                    </div>
                </form>

                <div class="user-menu">
                    <%-- 로그인/로그아웃으로 session에 값에 따라 변경 --%>
                    <c:if test="${empty user}">
                        <a href="/login.do" class="menu-item" id="login">
                            <span class="menu-icon">
                                <img src="${pageContext.request.contextPath}/images/login.png">
                            </span>
                            <div>로그인</div>
                        </a>
                    </c:if>
                    <c:if test="${!empty user}">
                        <a href="#" class="menu-item" id="login" onClick="logout(); return false;" >
                            <span class="menu-icon">
                                <img src="${pageContext.request.contextPath}/images/login.png">
                            </span>
                            <div>로그아웃</div>
                        </a>
                    </c:if>
                    <%-- ------------------------------------------ --%>

                    <a href="/register_form.do" class="menu-item">
                        <span class="menu-icon">
                            <img src="${pageContext.request.contextPath}/images/login.png">
                        </span>
                        <div>회원가입</div>
                    </a>

                    <a href="${pageContext.request.contextPath}/mypage.do" class="menu-item">
                        <span class="menu-icon">
                            <img src="${pageContext.request.contextPath}/images/mypage.png">
                        </span>
                        <div>마이페이지</div>
                    </a>
                </div>
            </div>

            <%-- 레시피에 접속시 class="active"를 레시피 li에 적용하게 전부 변경 --%>
            <ul class="nav-bar">
                <li class="active"><a href="/main_list.do">홈</a></li>
                <li>레시피</li>
                <li>랭킹</li>
                <li><a href="/list.do">커뮤니티</a></li>
                <li><a href="/fridge_list.do?member_id=${user.member_id}">냉장고 추천</a></li>
                <li><a href="/guide_list.do">키친가이드</a></li>
            </ul>
        </header>

        <canvas id="canvas3d"></canvas>
        
        <!-- 챗봇 -->
        <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />
        <footer>
            <div class="footer-container">
                <div class="footer-top-row">
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
                        <a href="/terms.do"><strong>이용약관</strong></a>
                        <a href="/privacy.do"><strong>개인정보처리방침</strong></a>
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
                        <p>주소 : 경기도 성남시 분당구 판교로 216길 92, kh타워 22층 2201호( 삼평동, 판교 에이치스퀘어 ) &nbsp;&nbsp; 이메일: kh@culture.net</p>
                    </div>

                    <div class="footer-logo-area">
                        <p class="copyright">© 2026 by Khculture. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </footer>
    </body>
</html>