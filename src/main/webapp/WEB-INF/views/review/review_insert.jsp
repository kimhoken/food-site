<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/navibar.jsp" />
<jsp:include page="/WEB-INF/views/common/is_login.jsp" />

<html>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.2/css/all.min.css">
    <link rel="stylesheet" href="/css/review.css" />
    <script>

        // 평점과 제목을 검증한 뒤 후기 등록 요청을 전송
        function review_send(f) {
            let rating = f.rating.value;
            let title = f.title.value;

            if (rating === '0') {
                alert("평점을 입력해주세요");
                return;
            }

            if (title.trim() === '') {
                alert("후기 제목을 입력해주세요");
                return;
            }

            let formdata = new FormData(f);

            fetch("/review/insert", {
                method: 'post',
                body: formdata
            })
                .then(res => res.json())
                .then(data => {
                    if (data.result == "success") {
                        alert("레시피 후기 등록 성공!");
                        location.href = '/list.do?btn=review';
                    } else if (data.result == "fail") {
                        alert("등록에 실패했습니다.");
                    } else {
                        alert("오류가 발생했습니다.");
                    }
                })
        }

        // 화면 로드 후 첨부 이미지 미리보기 이벤트를 등록
        document.addEventListener("DOMContentLoaded", () => {
            const fileInput = document.getElementById("reviewPhotos");
            const previewBox = document.getElementById("previewBox");

            if (previewBox) {
                // 기존 미리보기 영역을 초기화
                previewBox.innerHTML = "";
            }

            if (fileInput && previewBox) {
                // 새로 선택한 이미지 파일들을 미리보기로 표시
                fileInput.addEventListener("change", function () {
                    previewBox.innerHTML = "";

                    Array.from(this.files).forEach(file => {
                        const img = document.createElement("img");
                        // 선택한 이미지 파일을 임시 URL로 만들어 미리보기 이미지에 적용
                        img.src = URL.createObjectURL(file);
                        img.className = "preview-img";
                        previewBox.appendChild(img);
                    });
                });
            }
        })

    </script>
</head>

<body>

    <main class="review-write-page">

        <div class="review-write-head">

            <span class="review-write-kicker">레시피 후기</span>
            <h3>레시피 후기 등록</h3>
            <small>직접 만들어본 경험을 사진과 함께 공유해보세요.</small>

        </div>

        <form class="review-write-form" enctype="multipart/form-data" method="post">

            <input type="hidden" name="recipe_id" value="${param.recipe_id}" />

            <div class="review-write-layout">
                <%-- 후기 작성 대상 레시피 요약 영역 --%>
                <aside class="review-recipe-card">

                    <c:choose>

                        <c:when test="${not empty recipe.thumbnail}">
                            <img src="/upload/recipe/${recipe.thumbnail}" alt="${recipe.title}" />
                        </c:when>

                        <c:otherwise>
                            <img src="/images/no_image.png" alt="이미지 없음" />
                        </c:otherwise>

                    </c:choose>

                    <div class="review-recipe-info">

                        <span class="review-recipe-label">후기를 남길 레시피</span>
                        <h4>${recipe.title}</h4>

                        <div class="review-recipe-meta">

                            <span>${empty recipe.category_name ? '카테고리 없음' : recipe.category_name}</span>
                            <span>${recipe.cooking_time}</span>

                        </div>

                    </div>
                </aside>

                <%-- 별점 선택 영역 --%>
                <div class="review-field review-rating-field">
                    <label>평점 <span>*</span></label>
                    <input type="hidden" name="rating" id="rating" value="0">

                    <div class="rating">
                        <span class="rating__result">0</span>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                        <i class="rating__star far fa-star"></i>
                    </div>
                </div>

                <%-- 후기 제목 입력 영역 --%>
                <div class="review-field">

                    <label>후기 제목 <span>*</span></label>
                    <input type="text" name="title" placeholder="후기 제목 입력" />

                </div>


                <%-- 후기 내용 입력 영역 --%>
                <div class="review-field">

                    <label>후기 내용 <span>*</span></label>
                    <textarea name="content"
                              placeholder="레시피를 만들다가 느낌 감정을 공유해 주세요"></textarea>

                </div>

                <%-- 후기 이미지 첨부 및 미리보기 영역 --%>
                <div class="review-field">

                    <label>후기 사진</label>
                    <label class="review-file-label" for="reviewPhotos">사진 선택</label>
                    <input class="review-file-input" 
                           type="file" 
                           id="reviewPhotos" 
                           name="photo" 
                           multiple />
                    <div id="previewBox" class="preview-box"></div>

                </div>

            </div>

            <%-- 후기 등록/취소 버튼 영역 --%>
            <div class="review-write-actions">
                <input class="review-btn review-btn-sub" type="button" value="취소" onclick="history.back()" />
                <input class="review-btn review-btn-main" type="button" value="후기 등록" onclick="review_send(this.form)" />
            </div>
        </form>
    </main>
</body>

<script>
    // 별점 요소와 결과 표시 영역을 가져옴
    const ratingStars = [...document.getElementsByClassName("rating__star")];
    const ratingResult = document.querySelector(".rating__result");

    // 선택한 별점 값을 화면과 hidden input에 반영
    function printRatingResult(result, num = 0) {
        result.textContent = num;
        document.getElementById("rating").value = num;
    }

    printRatingResult(ratingResult);

    // 별 클릭 이벤트를 등록하고 선택된 별 개수를 갱신
    function executeRating(stars, result) {
        const starClassActive = "rating__star fas fa-star";
        const starClassUnactive = "rating__star far fa-star";
        const starsLength = stars.length;
        let i;

        stars.map((star) => {
            star.onclick = () => {
                i = stars.indexOf(star);

                if (star.className.indexOf(starClassUnactive) !== -1) {
                    printRatingResult(result, i + 1);

                    for (i; i >= 0; --i) {
                        stars[i].className = starClassActive;
                    }
                } else {
                    printRatingResult(result, i);

                    for (i; i < starsLength; ++i) {
                        stars[i].className = starClassUnactive;
                    }
                }
            };
        });
    }

    executeRating(ratingStars, ratingResult);
</script>

</html>
