<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <head>
            <link rel="stylesheet" href="css/mypage_activity.css" />
        </head>

        <section class="bookmark-page">
            <div class="activity-box bookmark-box">

                <div class="activity-header">                    
                    <h3>내가 쓴 북마크</h3>

                    <select onchange="location.href='/mypage.do?menu=bookmark&sort='+ this.value">
                        <option value="recently">최신순</option>
                        <option value="asc">오름차순</option>
                        <option value="desc">내림차순</option>                        
                    </select>

                </div>

                <c:if test="${ empty list }">

                    <div class="bookmark-empty">
                        <div>북마크가 존재하지 않습니다.</div>

                        <input class="bookmark-btn" type="button" 
                               value="북마크 등록 하러 가기" 
                               onclick="location.href='recipe_list.do'" />
                    </div>

                </c:if>

                <!-- foreach문으로 돌릴 예정 -->
                <c:forEach var="bookmark" items="${list}">

                    <div class="activity-row">

                        <div class="activity-thumb">
                            <img src="/upload/recipe/${bookmark.thumbnail}" />
                        </div>

                        <div class="active-main">
                            <a href="/recipe_detail.do?recipe_id=${bookmark.recipe_id}"><strong>${bookmark.title}</strong></a>
                        </div>

                        <div class="activity-date">
                            <small>${bookmark.created_date}</small>
                        </div>

                    </div>

                </c:forEach>
                <!--  -->


                <c:set var="pageUrl" value="/mypage.do?menu=bookmark&sort=${sort}" scope="request" />
                <jsp:include page="/WEB-INF/views/common/paging.jsp" />


            </div>
        </section>
