<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/navibar.jsp">
    <jsp:param name="currentMenu" value="guide" />
</jsp:include>
<!DOCTYPE html>
    <html>

        <head>
            <title>키친가이드</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/guide.css">
            <link rel="stylesheet" href="/css/chatbot.css" />
            <script src="/js/chatbot.js"></script>
            <script>
                // 키친가이드 들어오면 자동 '전체보기' 
                // window.onload = function() {
                //     showTab('all');
                // };
                document.addEventListener("DOMContentLoaded", () => {
                    showTab('all');
                })
                function showTab(tabName) {
                    document.querySelectorAll(".tab-btn").forEach(function(btn) {
                        btn.classList.remove("active");
                    });
                    let targetBtn = document.getElementById(tabName);
                    if (targetBtn) {
                        targetBtn.classList.add("active");
                    }

                    fetch("${pageContext.request.contextPath}/guide_tab.do?tab=" + tabName, { method: "get" })
                    .then( function(res) { return res.json(); } ) 
                    .then( function(data) {
                        
                        let grid = document.getElementById("guideGrid");
                        grid.innerHTML = ""; 
                        
                        for (let i = 0; i < data.length; i++) {
                        let guide = data[i]; 
                        
                        // 소제목이 null일 때 화면에 'null'이라고 뜨는 걸 방지
                        let subTitle = guide.sub_title ? guide.sub_title : "";                   
                        let imgPath = "${pageContext.request.contextPath}/guide_img/" + guide.image;

                        //해당 guide-grid 클릭하면 guide_id로 상세페이지로 이동
                        let cardHtml = "<div class='guide-card-link' onclick=\"location.href='${pageContext.request.contextPath}/guide_detail.do?guide_id=" + guide.guide_id + "'\">" +
                        "  <div class='guide-card'>" +
                        "    <div class='card-img-box'>" +
                        "      <img src='" + imgPath + "' alt='가이드 이미지'>" +
                        "    </div>" +
                        "    <div class='card-info'>" +
                        "      <p>" + subTitle + "</p>" +
                        "      <h3 style='font-weight: 400;'>" + guide.title + "</h3>" +
                        "    </div>" +
                        "  </div>" +
                        "</div>";
                        grid.innerHTML += cardHtml;
                    }
                    })
                    .catch(function(error) {
                        console.error("데이터 로드 중 에러 발생:", error);
                    });
                }
            </script>

            <style>
                /* 배경 흰색 고정 */
                body{
                    background-color: #ffffff !important;
                }
            </style>
        </head>

        <body>

            <div class="guide-header-frame">
                <div class="guide-title-box">
                    <h1>키친 가이드</h1>
                    <h2>일상이 깊어지는 곳, 당신만의 주방 가이드</h2>
                </div>
            </div>
            &nbsp;

            <div class="guide-container">
                <div class="category-tabs">
                    <button class="tab-btn" id="all" onclick="showTab('all')">전체보기</button>
                    <button class="tab-btn" id="storage" onclick="showTab('storage')">보관법</button>
                    <button class="tab-btn" id="trim" onclick="showTab('trim')">손질법</button>
                    <button class="tab-btn" id="tip" onclick="showTab('tip')">요리꿀팁</button>
                    <button class="tab-btn" id="etc" onclick="showTab('etc')">기타정보</button>
                </div>
            </div>


            <div class="guide-grid" id="guideGrid">

            </div>

            <!-- footer 회사 정보 jsp 파일 include -->
            <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
            <!-- 챗봇 -->
            <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

        </body>

        </html>