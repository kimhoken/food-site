<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="profile-list-section">
    <div class="profile-section-title">
        <h3>작성 댓글</h3>
        <span>${commentCount}개</span>
    </div>

    <c:choose>
        <c:when test="${empty list}">
            <div class="profile-empty-state">
                <h3>작성한 댓글이 없습니다.</h3>
                <p>이 회원이 공개한 댓글이 아직 없습니다.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="profile-comment-board">
                <c:forEach var="comment" items="${list}">
                    <a href="/recipe_detail.do?recipe_id=${comment.recipe_id}" class="profile-comment-card">
                        <c:choose>
                            <c:when test="${empty comment.thumbnail or comment.thumbnail eq 'no_file.png'}">
                                <img src="/images/no_file.png" alt="" />
                            </c:when>
                            <c:otherwise>
                                <img src="/upload/recipe/${comment.thumbnail}" alt="" />
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <strong>${comment.content}</strong>
                            <span>${comment.created_date}</span>
                        </div>
                    </a>
                </c:forEach>
            </div>

            <c:set var="pageUrl" value="/user/${member_id}?menu=comment" scope="request" />
            <jsp:include page="/WEB-INF/views/common/paging.jsp" />
        </c:otherwise>
    </c:choose>
</section>
