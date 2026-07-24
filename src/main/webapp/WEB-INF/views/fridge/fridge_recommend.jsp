<%@ page import="java.util.Random"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:if test="${empty sessionScope.user}">
    <script>
        alert("로그인후 이용해주세요.")
        location.href="/login.do";
    </script>
</c:if>

<c:if test="${sessionScope.user.member_id ne param.id}">
    <script>
        alert("권한이 없습니다.")
        location.href="/main_list.do";
    </script>
</c:if>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>오늘 뭐 먹지? - 냉장고 레시피 추천</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="/css/chatbot.css" />
        <script src="/js/chatbot.js"></script>
        <script>
        </script>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/navibar.jsp">
            <jsp:param name="currentMenu" value="fridge" />
        </jsp:include>

        <div class="container main-page">
            <div class="section-title">
                ${sessionScope.user.nickname}님을 위한 추천 레시피!
                <p>이런 메뉴는 어떠신가요?</p>
            </div>
            <div class="recipe-grid">
                <c:forEach var="recipe" items="${list}" varStatus="status">
                    <div class="recipe-card">
                        
                        <a href="recipe_detail.do?recipe_id=${recipe.recipe_id}">
                            
                            <div class="recipe-img">
                                
                                 <img src="/upload/recipe/${recipe.thumbnail}" alt="레시피 썸네일 이미지"> 
                            </div>
                            <%-- 순위 뱃지 적용 --%>
                            <div class="rank-badge">${status.index + 1}</div>
                            <div class="recipe-info">
                                <div class="recipe-name">${recipe.title}</div>
                                <div class="recipe-author">👤 ${recipe.nickname}</div>
                                <div class="recipe-meta">
                                    <span class="star-rating">★ 4.8</span>
                                    <span>조회수 <fmt:formatNumber value="${recipe.view_count}"/></span>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

        <!-- 챗봇 -->
        <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

    </body>
</html>