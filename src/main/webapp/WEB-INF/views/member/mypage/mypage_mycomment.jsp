<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>
            <link rel="stylesheet" href="css/mypage_activity.css" />
        </head>
        <section>
            <div class="activity-box">

                <div class="activity-header">
                    <h3>내가 쓴 댓글</h3>

                    <select onchange="location.href='/mypage.do?menu=comment&sort='+ this.value">
                        <option value="recently">최신순</option>
                        <option value="asc">오름차순</option>
                        <option value="desc">내림차순</option>                        
                    </select>
                    
                </div>

                <c:if test="${ empty list }">
                    <div>작성한 댓글이 존재하지 않습니다.</div>
                </c:if>

                <!-- foreach문 댓글 목록 조회 -->
                <c:forEach var="comment" items="${list}">

                    <div class="activity-row">

                        <div class="activity-thumb">
                            <img src="/upload/recipe/${comment.thumbnail}" />
                        </div>

                        <div class="active-main">
                            <a href="/recipe_detail.do?recipe_id=${comment.recipe_id}">
                                <strong>${comment.content}</strong>
                            </a>
                        </div>
                        
                        <div class="activity-date">
                            <small>${comment.created_date}</small>
                        </div>

                    </div>
                </c:forEach>
                <!--  -->


                <!-- 페이징 구현 해서 아래에 출력하게 하기 -->
                <c:set var="pageUrl" value="/mypage.do?menu=comment&sort=${sort}" scope="request" />
                <jsp:include page="/WEB-INF/views/common/paging.jsp" />
            </div>
        </section>
