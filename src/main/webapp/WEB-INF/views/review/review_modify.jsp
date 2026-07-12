<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/navibar.jsp" />
<jsp:include page="/WEB-INF/views/common/is_login.jsp" />

<html>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.2/css/all.min.css">
    <link rel="stylesheet" href="/css/review.css" />
    <script>
        // 삭제할 기존 이미지 파일명을 저장
        const deleteImages = [];

        // 화면 로드 후 추가 이미지 미리보기 이벤트를 등록
        document.addEventListener("DOMContentLoaded", () => {
            const fileInput = document.getElementById("reviewPhotos");
            const previewBox = document.getElementById("previewBox");

            if (fileInput && previewBox) {
                // 새로 추가한 이미지 파일을 미리보기 목록에 표시
                fileInput.addEventListener("change", function () {
                    Array.from(this.files).forEach(file => {
                        const item = document.createElement("div");
                        item.className = "preview-item";

                        const img = document.createElement("img");
                        // 선택한 이미지 파일을 임시 URL로 만들어 미리보기에 적용
                        img.src = URL.createObjectURL(file);
                        img.className = "preview-img";

                        item.appendChild(img);
                        previewBox.appendChild(item);
                    });
                });
            }
        });

        // 기존 이미지 삭제 목록에 파일명을 추가하고 화면에서 제거
        function deleteImage(btn, imageName) {
            deleteImages.push(imageName);
            btn.closest(".preview-item").remove();
        }

        // 수정 폼 데이터와 삭제 이미지 목록을 함께 서버로 전송
        function review_modify(f) {
            const formdata = new FormData(f);

            // 삭제할 이미지 목록을 쉼표로 묶어 multipart 요청에 포함
            formdata.set("deleteImages", deleteImages.join(","));

            fetch("/review/modify", {
                method: 'post',
                body: formdata
            })
                .then(res => res.json())
                .then(data => {
                    if (data.img_res > 0) {
                        alert("이미지 수정이 완료되었습니다.");
                    } else {
                        alert("이미지는 변경되지 않았습니다.");
                    }

                    if (data.review_res > 0) {
                        alert("후기 수정이 완료되었습니다.");
                        location.href = "/list.do?btn=review";
                    } else {
                        alert("후기 수정에 실패했습니다.");
                        alert(data.text);
                    }
                });
        }
    </script>
</head>

<body>
    <main class="review-write-page">
        <div class="review-write-head">
            <span class="review-write-kicker">레시피 후기</span>
            <h3>레시피 후기 수정</h3>
            <small>작성한 후기를 다시 정리하고 사진을 관리해보세요.</small>
        </div>

        <form class="review-write-form" enctype="multipart/form-data" method="post">
            <input type="hidden" name="review_id" value="${review.review_id}" />
            <input type="hidden" name="img_id" value="${review.img_id}" />
            <input type="hidden" name="deleteImages" id="deleteImages" />

            <div class="review-write-layout">
                <%-- 수정 중인 후기의 레시피 요약 영역 --%>
                <aside class="review-recipe-card">
                    <c:choose>
                        <c:when test="${not empty review.recipe_thumbnail}">
                            <img src="/upload/review/${review.recipe_thumbnail}" alt="${review.recipe_title}" />
                        </c:when>
                        <c:otherwise>
                            <img src="/images/no_file.png" alt="이미지 없음" />
                        </c:otherwise>
                    </c:choose>

                    <div class="review-recipe-info">
                        <span class="review-recipe-label">수정 중인 후기</span>
                        <h4>${review.recipe_title}</h4>
                        <div class="review-recipe-meta">
                            <span>내가 작성한 레시피 후기</span>
                        </div>
                    </div>
                </aside>

                <%-- 별점 수정 영역 --%>
                <div class="review-field review-rating-field">
                    <label>평점 <span>*</span></label>
                    <input type="hidden" name="rating" id="rating" value="${review.rating}">

                    <div class="rating">
                        <span class="rating__result">0</span>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                    </div>
                </div>

                <%-- 후기 제목 수정 영역 --%>
                <div class="review-field">
                    <label>후기 제목 <span>*</span></label>
                    <input type="text" name="title" value="${review.title}" />
                </div>

                <%-- 후기 내용 수정 영역 --%>
                <div class="review-field">
                    <label>후기 내용 <span>*</span></label>
                    <textarea name="content">${review.content}</textarea>
                </div>

                <%-- 기존 후기 이미지 목록 및 추가 이미지 첨부 영역 --%>
                <div class="review-field">
                    <label>후기 사진</label>
                    <label class="review-file-label" for="reviewPhotos">사진 추가</label>
                    <input class="review-file-input" type="file" id="reviewPhotos" name="photo" multiple />

                    <div id="previewBox" class="preview-box">
                        <c:forEach var="img" items="${review.imgList}">
                            <div class="preview-item">
                                <img src="/upload/review/${img}" class="preview-img" alt="후기 사진" />
                                
                                    <input type="button"
                                           class="preview-delete-btn" 
                                           value="x"
                                           onclick="deleteImage(this, '${img}')"  />
                                    삭제
                                
                            </div>
                        </c:forEach>
                    </div>

                    
                </div>
            </div>

            <%-- 후기 수정/취소 버튼 영역 --%>
            <div class="review-write-actions">
                <input class="review-btn review-btn-sub" type="button" value="취소" onclick="history.back()" />
                <input class="review-btn review-btn-main" type="button" value="후기 수정" onclick="review_modify(this.form)" />
            </div>
        </form>
    </main>
</body>

<script>
    // 별점 요소와 결과 표시 영역을 가져옴
    const ratingStars = [...document.getElementsByClassName("rating__star")];
    const ratingResult = document.querySelector(".rating__result");
    const ratingInput = document.getElementById("rating");

    // 선택한 별점 값을 화면과 hidden input에 반영
    function printRatingResult(result, num = 0) {
        result.textContent = num;
        ratingInput.value = num;
    }

    // 선택한 별점 개수만큼 별 아이콘을 채움
    function paintStars(num) {
        ratingStars.forEach((star, index) => {
            star.className = index < num
                ? "rating__star fas fa-star"
                : "rating__star far fa-star";
        });
    }

    // 현재 후기의 기존 별점 값을 화면과 hidden input에 반영
    const initialRating = Number(ratingInput.value || 0);
    printRatingResult(ratingResult, initialRating);
    paintStars(initialRating);

    // 별 클릭 시 기존 별점을 토글하고 화면 상태를 갱신
    function executeRating(stars, result) {
        stars.forEach((star, index) => {
            star.onclick = () => {
                const currentRating = Number(ratingInput.value || 0);
                const nextRating = currentRating === index + 1 ? index : index + 1;

                printRatingResult(result, nextRating);
                paintStars(nextRating);
            };
        });
    }

    executeRating(ratingStars, ratingResult);
</script>

</html>
