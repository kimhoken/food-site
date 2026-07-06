<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="separator" value="${fn:contains(pageUrl, '?') ? '&' : '?'}" />

<nav class="paging" aria-label="페이지 이동">
    <c:if test="${paging.prev}">
        <a class="paging-link paging-prev" href="${pageUrl}${separator}page=${paging.startpage - 1}">이전</a>
    </c:if>

    <c:forEach var="p" begin="${paging.startpage}" end="${paging.endpage}">
        <a class="paging-link ${paging.page == p ? 'active' : ''}" href="${pageUrl}${separator}page=${p}">
            ${p}
        </a>
    </c:forEach>

    <c:if test="${paging.next}">
        <a class="paging-link paging-next" href="${pageUrl}${separator}page=${paging.endpage + 1}">다음</a>
    </c:if>
</nav>
