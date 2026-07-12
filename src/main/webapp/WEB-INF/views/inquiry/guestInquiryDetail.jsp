<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/css/guestInquiryDetail.css">
</head>

<body>

<div class="inquiry-page">

    <div class="inquiry-form">

        <div class="inquiry-title-box">
            <span class="inquiry-label">INQUIRY ANSWER</span>
            <h2>문의 답변 확인</h2>
            <p>
                문의 내용과 관리자 답변을 확인할 수 있습니다.
            </p>
        </div>

        <table class="inquiry-table">

            <tr>
                <th>문의번호</th>
                <td>${vo.inquiry_id}</td>
            </tr>

            <tr>
                <th>문의유형</th>
                <td>${vo.type}</td>
            </tr>

            <tr>
                <th>제목</th>
                <td>${vo.title}</td>
            </tr>

            <tr>
                <th>문의내용</th>
                <td class="content-box">${vo.content}</td>
            </tr>

            <!-- 첨부 이미지가 존재하는 경우에만 출력 -->
            <c:if test="${not empty imgList}">
                <tr>
                    <th>첨부이미지</th>
                    <td>
                        <div class="image-list">
                            <c:forEach var="img" items="${imgList}">
                                <img src="/upload/${img.image_list}"
                                     alt="첨부이미지"
                                     onclick="openImageModal(this.src)"
                                     style="cursor:pointer;">
                            </c:forEach>

                        </div>
                    </td>
                </tr>
            </c:if>

            <tr>
                <th>작성일</th>
                <td>
                    <fmt:formatDate
                        value="${vo.created_date}"
                        pattern="yyyy-MM-dd HH:mm"/>
                </td>
            </tr>

            <!-- 문의 처리 상태에 따라 답변 완료 또는 대기로 표시 -->
            <tr>
                <th>답변상태</th>
                <td>

                    <c:choose>

                        <c:when test="${vo.status eq 'y'}">
                            <span class="status-complete">
                                답변 완료
                            </span>
                        </c:when>

                        <c:otherwise>
                            <span class="status-wait">
                                답변 대기
                            </span>
                        </c:otherwise>

                    </c:choose>

                </td>
            </tr>

             <!-- 답변이 없을 경우 안내 문구 출력 -->
            <tr>
                <th>관리자 답변</th>

                <td>

                    <div class="answer-box">

                        <c:choose>

                            <c:when test="${not empty vo.answer_content}">
                                ${vo.answer_content}
                            </c:when>

                            <c:otherwise>
                                아직 답변이 등록되지 않았습니다.
                            </c:otherwise>

                        </c:choose>

                    </div>

                </td>
            </tr>

            <tr>
                <th>답변일</th>
                <td>

                    <c:if test="${not empty vo.answered_date}">
                        <fmt:formatDate
                            value="${vo.answered_date}"
                            pattern="yyyy-MM-dd HH:mm"/>
                    </c:if>

                </td>
            </tr>

        </table>

        <div class="btn-area">
            <input type="button"
                   value="메인으로"
                   class="cancel-btn"
                   onclick="location.href='/main_list.do'">
        </div>

    </div>

</div>

</body>
<!-- 첨부 이미지 확대 모달 -->
<div id="imageModal" class="image-modal" onclick="closeImageModal()">
    <span class="image-modal-close">&times;</span>
    <img id="modalImage" class="image-modal-content">
</div>

<script>
    function openImageModal(src) {
        document.getElementById("imageModal").style.display = "flex";
        document.getElementById("modalImage").src = src;
    }

    function closeImageModal() {
        document.getElementById("imageModal").style.display = "none";
    }
</script>
</html>