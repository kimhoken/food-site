<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="profile-list-section">
    <div class="profile-section-title">
        <h3>작성 레시피</h3>
        <span>${recipeCount}개</span>
    </div>

    <c:choose>
        <c:when test="${empty list}">
            <div class="profile-empty-state">
                <h3>작성한 레시피가 없습니다.</h3>
                <p>이 회원이 공개한 레시피가 아직 없습니다.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="profile-recipe-grid">
                <c:forEach var="recipe" items="${list}">
                    <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}" class="profile-recipe-card">
                        <c:choose>
                            <c:when test="${empty recipe.thumbnail or recipe.thumbnail eq 'no_file.png'}">
                                <img src="/images/no_file.png" alt="" />
                            </c:when>
                            <c:otherwise>
                                <img src="/upload/recipe/${recipe.thumbnail}" alt="" />
                            </c:otherwise>
                        </c:choose>
                        <div class="profile-recipe-info">
                            <strong>${recipe.title}</strong>
                            <span>${recipe.created_date}</span>
                        </div>
                    </a>
                </c:forEach>
            </div>

            <c:set var="pageUrl" value="/user/${member_id}?menu=recipe" scope="request" />
            <jsp:include page="/WEB-INF/views/common/paging.jsp" />
        </c:otherwise>
    </c:choose>
</section>
