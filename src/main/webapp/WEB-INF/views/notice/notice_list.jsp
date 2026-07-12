<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>

<head>

    <link rel="stylesheet" href="/css/main.css">
    <link rel="stylesheet" href="/css/notice.css">

    <script>
        // 로그아웃 요청 후 성공 시 공지사항 목록으로 이동
        const logout = () => {
            if (confirm("로그아웃 하시겠습니까?")) {
                fetch("/logout.do", {
                    method: "post",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        id: "${user.member_id}"
                    })
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.result == "success") {
                            alert("로그아웃 되었습니다.");
                            location.href = "/notice.do";
                        }
                    });
            }
        }
    </script>
</head>

<body>
    <jsp:include page="/WEB-INF/views/common/navibar.jsp" />

    <div class="notice-wrap">

        <div class="notice-title">
            <span class="notice-label">NOTICE</span>
            <h2>공지사항</h2>
        </div>

        <div class="notice-content">

            <div class="notice-top">
                <!-- 제목을 기준으로 공지사항 검색 -->
                <div class="notice-search-box">
                    <form action="notice.do" method="get">
                        <input type="text" name="search_text" value="${search_text}" placeholder="제목을 입력해 주세요.">
                        <button type="submit">⌕</button>
                    </form>
                </div>
            </div>

            <div class="table-radius-box">
                <table class="notice-table">
                    <tr>
                        <th>번호</th>
                        <th>제목</th>
                        <th>작성자</th>
                        <th>작성일</th>
                        <th>조회수</th>
                    </tr>

                    <!-- 검색 결과 또는 등록된 공지사항이 없는 경우 -->
                    <c:if test="${totalCount == 0}">
                        <tr>
                            <td colspan="5" class="no-result">
                                관련된 게시물이 없습니다.
                            </td>
                        </tr>
                    </c:if>

                    <!-- 공지사항 목록 출력 -->
                    <c:if test="${totalCount > 0}">
                        <c:forEach var="vo" items="${notice}">
                            <tr>
                                <td>${vo.notice_id}</td>

                                <td>
                                    <a href="notice_detail.do?notice_id=${vo.notice_id}">
                                        ${vo.title}
                                    </a>
                                </td>

                                <td>${vo.member_id}</td>

                                <td>
                                    <fmt:formatDate value="${vo.created_date}" pattern="yyyy-MM-dd" />
                                </td>

                                <td>${vo.view_count}</td>
                            </tr>
                        </c:forEach>
                    </c:if>
                </table>
            </div>

            <div class="paging-box">
                <div class="page-menu">
                    ${pageMenu}
                </div>

                <!-- 관리자에게만 공지 등록 버튼 표시 -->
                <c:if test="${user.role eq 'ADMIN'}">
                    <input class="notice-write-btn" type="button" value="공지등록"
                        onclick="location.href='notice_add.do'" />
                </c:if>
            </div>

        </div>

    </div>
</body>

</html>