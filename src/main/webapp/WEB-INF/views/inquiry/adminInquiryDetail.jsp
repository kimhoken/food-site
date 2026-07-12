<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/css/adminInquiryDetail.css">

    <script>
        function sendAnswer(f) {
            const answer = f.answer_content.value.trim();

            if (answer === "") {
                alert("답변 내용을 입력하세요.");
                f.answer_content.focus();
                return;
            }

            if (!confirm("답변을 등록하시겠습니까?")) {
                return;
            }

            f.submit();
        }
        // 첨부 이미지를 원본 크기의 모달로 표시
        function openImageModal(src) {
            document.getElementById("imageModal").style.display = "flex";
            document.getElementById("modalImage").src = src;
        }

        function closeImageModal() {
            document.getElementById("imageModal").style.display = "none";
        }
    </script>
</head>

<body>

<div class="admin-inquiry-page">

    <div class="admin-inquiry-form">

        <div class="admin-title-box">
            <h2>문의 상세</h2>
            <p>사용자가 남긴 문의 내용을 확인하고 답변을 등록할 수 있습니다.</p>
        </div>

        <table class="admin-table">
            <tr>
                <th>문의번호</th>
                <td>${vo.inquiry_id}</td>
            </tr>

            <tr>
                <th>유형</th>
                <td>${vo.type}</td>
            </tr>

            <tr>
                <th>제목</th>
                <td>${vo.title}</td>
            </tr>

            <tr>
                <th>내용</th>
                <td class="content-box">${vo.content}</td>
            </tr>

            <c:if test="${not empty imgList}">
                <tr>
                    <th>첨부 이미지</th>
                    <td>
                        <div class="image-list">
                            <c:forEach var="img" items="${imgList}">
                                <img src="/upload/${img.image_list}"
                                    class="inquiry-img"
                                    onclick="openImageModal(this.src)">
                            </c:forEach>
                        </div>
                    </td>
                </tr>
            </c:if>

            <!-- 회원 문의와 비회원 문의의 작성자 정보를 구분하여 출력 -->
            <tr>
                <th>작성자</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty vo.member_id}">
                            ${vo.nickname}
                        </c:when>
                        <c:otherwise>
                            비회원 (${vo.guest_name} / ${vo.guest_email})
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>

            <tr>
                <th>작성일</th>
                <td>
                    <fmt:formatDate value="${vo.created_date}" pattern="yyyy-MM-dd HH:mm"/>
                </td>
            </tr>

            <!-- 문의 처리 상태에 따라 답변 완료 또는 대기로 표시 -->
            <tr>
                <th>답변상태</th>
                <td>
                    <c:choose>
                        <c:when test="${vo.status eq 'y'}">
                            <span class="status-complete">답변 완료</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-wait">답변 대기</span>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>

            <!-- 비회원 문의에 발급된 조회 코드가 있을 때만 출력 -->
            <c:if test="${not empty vo.inquiry_code}">
                <tr>
                    <th>문의코드</th>
                    <td>${vo.inquiry_code}</td>
                </tr>
            </c:if>
        </table>

        <!-- 첨부 이미지 확대 모달 -->
        <div id="imageModal" class="image-modal" onclick="closeImageModal()">
            <div class="image-modal-box" onclick="event.stopPropagation()">
                <button type="button" class="image-modal-close" onclick="closeImageModal()">
                    &times;
                </button>
                <img id="modalImage" class="image-modal-content">
            </div>
        </div>

        <form action="/inquiry/admin/answer" method="post" class="answer-form">

            <input type="hidden" name="inquiry_id" value="${vo.inquiry_id}">

            <div class="answer-title">관리자 답변</div>

            <textarea name="answer_content" placeholder="답변 내용을 입력하세요.">${vo.answer_content}</textarea>

            <c:if test="${not empty vo.answered_date}">
                <div class="answered-date">
                    답변일:
                    <fmt:formatDate value="${vo.answered_date}" pattern="yyyy-MM-dd HH:mm"/>
                </div>
            </c:if>

            <div class="btn-area">
                <input type="button" value="답변 등록" class="submit-btn" onclick="sendAnswer(this.form)">
                <input type="button" value="목록" class="cancel-btn" onclick="location.href='/admin/inquiry'">
            </div>

        </form>

    </div>

</div>

</body>
</html>