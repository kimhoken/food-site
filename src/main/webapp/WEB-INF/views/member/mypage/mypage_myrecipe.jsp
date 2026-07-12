<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

        <head>
            <link rel="stylesheet" href="css/mypage_activity.css" />
        </head>

        <section>
            <div class="activity-box">
                <div class="activity-header">

                    <h3>내가 쓴 레시피</h3>
                    <select onchange="location.href='/mypage.do?menu=recipe&sort='+ this.value">
                        <option value="recently" ${sort eq 'recently' ? 'selected' : ''}>최신순</option>
                        <option value="asc" ${sort eq 'asc' ? 'selected' : ''}>오름차순</option>
                        <option value="desc" ${sort eq 'desc' ? 'selected' : ''}>내림차순</option>
                        <option value="view" ${sort eq 'view' ? 'selected' : ''}>조회수순</option>
                    </select>
                    
                </div>

                <c:if test="${ empty list }">
                    <div>작성한 레시피가 존재하지 않습니다.</div>
                    <input type="button" value="레시피 등록 하러 가기" onclick="location.href='/regiRecipe.do?id=${sessionScope.user.member_id}'" />
                </c:if>

                <c:if test="${ not empty list }">
                    <c:forEach var="recipe" items="${list}">

                        <div class="activity-row">

                            <div class="activity-thumb">
                                <img src="/upload/recipe/${recipe.thumbnail}" />
                            </div>

                        <div class="active-main">
                            <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}">
                                <strong>${recipe.title}</strong>
                            </a>
                        </div>

                        <div class="activity-date">
                            <small> 등록일: ${recipe.created_date.substring(0,10).replace('-','.')}</small>
                        </div>

                        <div class="activity-extra">
                           조회: ${recipe.view_count}
                        </div>

                    </div>

                </c:forEach>

                    
                </c:if>


                <c:set var="pageUrl" value="/mypage.do?menu=recipe&sort=${sort}" scope="request" />
                <jsp:include page="/WEB-INF/views/common/paging.jsp" />

            </div>
        </section>
