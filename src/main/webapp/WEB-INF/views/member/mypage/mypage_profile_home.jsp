<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="profile-home-grid">
    <div class="profile-panel">
        <div class="profile-panel-header">
            <h3>최근 작성 레시피</h3>
            <a href="/user/${member_id}?menu=recipe">전체보기</a>
        </div>

        <c:choose>
            <c:when test="${empty recentlyRecipeList}">
                <div class="profile-list-empty">아직 작성한 레시피가 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="profile-card-list">
                    <c:forEach var="recipe" items="${recentlyRecipeList}">
                        <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}" class="profile-list-card">
                            <c:choose>
                                <c:when test="${empty recipe.thumbnail or recipe.thumbnail eq 'no_file.png'}">
                                    <img src="/images/no_file.png" alt="" />
                                </c:when>
                                <c:otherwise>
                                    <img src="/upload/recipe/${recipe.thumbnail}" alt="" />
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <strong>${recipe.title}</strong>
                                <span>${recipe.created_date}</span>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="profile-panel">
        <div class="profile-panel-header">
            <h3>최근 작성 댓글</h3>
            <a href="/user/${member_id}?menu=comment">전체보기</a>
        </div>

        <c:choose>
            <c:when test="${empty commentList}">
                <div class="profile-list-empty">아직 작성한 댓글이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <div class="profile-comment-list">
                    <c:forEach var="comment" items="${commentList}">
                        <a href="/recipe_detail.do?recipe_id=${comment.recipe_id}" class="profile-comment-item">
                            <strong>${comment.content}</strong>
                            <span>${comment.created_date}</span>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>
