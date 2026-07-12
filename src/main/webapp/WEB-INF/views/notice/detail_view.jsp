<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="/css/main.css">
        <link rel="stylesheet" href="/css/notice_detail.css">

        <script>
            function deleteNotice() {
                if (confirm("삭제하시겠습니까?")) {
                    location.href = "notice_delete.do?notice_id=${notice.notice_id}";
                }
            }
            // 클릭한 공지 이미지를 모달창에 확대 표시
            function openImageModal(src) {
                document.getElementById("imageModal").style.display = "flex";
                document.getElementById("modalImage").src = src;
            }

            // 이미지 모달창을 닫고 기존 이미지 경로 초기화
            function closeImageModal() {
                document.getElementById("imageModal").style.display = "none";
                document.getElementById("modalImage").src = "";
            }
        </script>
    </head>

    <body>
        <jsp:include page="/WEB-INF/views/common/navibar.jsp" />

        <main class="notice-detail-page">

            <section class="detail-head">
                <span>NOTICE DETAIL</span>
                <h2>공지사항</h2>
            </section>

            <section class="detail-card">

                <div class="detail-title-area">
                    <p class="detail-no">NO. ${notice.notice_id}</p>
                    <h3>${notice.title}</h3>

                    <div class="detail-meta">
                        <span>작성자 ${notice.member_id}</span>
                        <span>
                            <fmt:formatDate value="${notice.created_date}" pattern="yyyy-MM-dd HH:mm:ss" />
                        </span>
                        <span>조회수 ${notice.view_count}</span>
                    </div>
                </div>

                <div class="detail-content">

                    <c:if test="${not empty img and not empty img.image_list}">
                        <div class="detail-img-box">

                            <%-- 쉼표로 저장된 이미지 파일명을 나누어 반복 출력 --%>
                           <c:forEach var="fileName" items="${fn:split(img.image_list, ',')}">
                                <div class="detail-img-item"
                                    onclick="openImageModal('/upload/${fileName}')">

                                    <img src="/upload/${fileName}" alt="공지 이미지">

                                </div>
                            </c:forEach>

                        </div>
                    </c:if>

                    <p>${notice.content}</p>
                </div>

                <div class="detail-btn-area">
                    <%-- 관리자만 수정 및 삭제 버튼 사용 가능 --%>
                    <c:if test="${sessionScope.user.role eq 'ADMIN'}">
                        <input type="button"
                            class="edit-btn"
                            value="수정"
                            onclick="location.href='notice_update.do?notice_id=${notice.notice_id}'">

                        <input type="button"
                            class="delete-btn"
                            value="삭제"
                            onclick="deleteNotice()">
                    </c:if>

                    <input type="button"
                        class="list-btn"
                        value="목록"
                        onclick="location.href='notice.do'">
                </div>

            </section>

        </main>
        <%-- 공지 이미지 확대 확인용 모달창 --%>
        <div id="imageModal" class="image-modal" onclick="closeImageModal()">
            <button type="button" class="image-modal-close" onclick="closeImageModal()">×</button>
            <img id="modalImage" src="" alt="확대 이미지" onclick="event.stopPropagation()">
        </div>
    </body>
</html>