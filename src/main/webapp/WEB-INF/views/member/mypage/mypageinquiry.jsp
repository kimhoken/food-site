<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="/css/mypageinquiry.css">

<script>
    function toggleInquiry(id) {
        const item = document.getElementById("inquiry-" + id);

        if (item.classList.contains("open")) {
            item.classList.remove("open");
        } else {
            item.classList.add("open");
        }
    }

    function openImageModal(src) {
        const modal = document.getElementById("imageModal");
        const modalImg = document.getElementById("modalImage");

        modalImg.src = src;
        modal.style.display = "flex";
    }

    function closeImageModal() {
        const modal = document.getElementById("imageModal");
        const modalImg = document.getElementById("modalImage");

        modal.style.display = "none";
        modalImg.src = "";
    }
    function updateExpireCount() {
        const items = document.querySelectorAll(".expire-count");

        items.forEach(item => {
            const createdText = item.dataset.created.replace(" ", "T");
            const limitSeconds = Number(item.dataset.limit);

            const createdTime = new Date(createdText).getTime();
            const expireTime = createdTime + (limitSeconds * 1000);
            const now = new Date().getTime();

            let remain = Math.floor((expireTime - now) / 1000);

            if (remain <= 0) {
            const card = item.closest(".inquiry-card");
            if (card) {
                card.remove();
                }
                return;
            }
            // 유효기간 30초 남았을 때 메세지 띄움
            if (remain <= 30) {
                item.textContent = remain + "초 남음";
            } else {
                item.textContent = "";
            }
        });
    }

    setInterval(updateExpireCount, 1000);
    window.addEventListener("load", updateExpireCount);

</script>

<div class="my-inquiry-wrap">

    <div class="my-inquiry-top">
        <div>
            <h2>문의 내역</h2>
        </div>
    </div>

    <div class="inquiry-filter-row">

        <button type="button"
                class="${empty status ? 'active' : ''}"
                onclick="location.href='/mypage.do?menu=inquiry'">
            전체
        </button>

        <button type="button"
                class="${status eq 'n' ? 'active' : ''}"
                onclick="location.href='/mypage.do?menu=inquiry&status=n'">
            답변대기
        </button>

        <button type="button"
                class="${status eq 'y' ? 'active' : ''}"
                onclick="location.href='/mypage.do?menu=inquiry&status=y'">
            답변완료
        </button>

    </div>

    <div class="inquiry-list">

        <c:choose>
            <c:when test="${empty inquiryList}">
                <div class="empty-box">
                    작성한 문의가 없습니다.
                </div>
            </c:when>

            <c:otherwise>
                <c:forEach var="vo" items="${inquiryList}">
                    <div class="inquiry-card" id="inquiry-${vo.inquiry_id}">

                        <div class="inquiry-summary"
                             onclick="toggleInquiry('${vo.inquiry_id}')">

                            <span class="arrow">›</span>

                            <span class="status ${vo.status eq 'y' ? 'done' : 'wait'}">
                                <c:choose>
                                    <c:when test="${vo.status eq 'y'}">답변완료</c:when>
                                    <c:otherwise>답변대기</c:otherwise>
                                </c:choose>
                            </span>

                            <strong class="title">${vo.title}</strong>

                            <span class="date">
                                <fmt:formatDate value="${vo.created_date}" pattern="yyyy.MM.dd"/>
                            </span>

                            <span class="expire-count"
                                data-created="<fmt:formatDate value='${vo.created_date}' pattern='yyyy-MM-dd HH:mm:ss'/>"
                                data-limit="100">
                                <!-- !!!!!100초 기준으로 지워짐!!!!!(맵퍼랑 같은 시간으로 변경해야함) -->
                            </span>
                        </div>

                        <div class="inquiry-detail">

                            <div class="question-box">
                                <p>${vo.content}</p>
                            </div>

                            <c:if test="${not empty inquiryImgMap[vo.inquiry_id]}">
                                <div class="my-inquiry-img-list">
                                    <c:forEach var="img" items="${inquiryImgMap[vo.inquiry_id]}">
                                        <img src="/upload/${img.image_list}"
                                             alt="첨부 이미지"
                                             onclick="event.stopPropagation(); openImageModal(this.src);">
                                    </c:forEach>
                                </div>
                            </c:if>

                            <c:if test="${vo.status eq 'y'}">
                                <div class="answer-box">
                                    <div class="answer-title">
                                        💬 관리자 답변

                                        <span>
                                            답변일 :
                                            <fmt:formatDate value="${vo.answered_date}" pattern="yyyy.MM.dd"/>
                                        </span>
                                    </div>

                                    <p>${vo.answer_content}</p>
                                </div>
                            </c:if>

                            <c:if test="${vo.status ne 'y'}">
                                <div class="answer-box waiting">
                                    아직 답변이 등록되지 않았습니다.
                                </div>
                            </c:if>

                        </div>

                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

    </div>

    <div class="inquiry-bottom-box">

        <div class="inquiry-total-count">
            전체 <strong>${totalcount}</strong>건
        </div>

        <div class="paging-box">
            
            <a href="/mypage.do?menu=inquiry&page=${startPage - 1}&status=${status}">
                ◀
            </a>

            <c:forEach begin="${startPage}" end="${endPage}" var="i">

                <c:choose>
                    <c:when test="${i == page}">
                        <strong>${i}</strong>
                    </c:when>

                    <c:otherwise>
                        <a href="/mypage.do?menu=inquiry&page=${i}&status=${status}">
                            ${i}
                        </a>
                    </c:otherwise>
                </c:choose>

            </c:forEach>
                
            <a href="/mypage.do?menu=inquiry&page=${endPage + 1}&status=${status}">
                ▶
            </a>       
        
        </div>

        <button type="button"
                class="write-inquiry-btn"
                onclick="location.href='/inquiry'">
            문의 작성
        </button>

    </div>

</div>

<div id="imageModal" class="image-modal" onclick="closeImageModal()">
    <button type="button"
            class="image-modal-close"
            onclick="event.stopPropagation(); closeImageModal();">
        ×
    </button>

    <img id="modalImage" src="" alt="확대 이미지" onclick="event.stopPropagation();">
</div>
