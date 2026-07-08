<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/common/navibar.jsp">
    <jsp:param name="currentMenu" value="home" />
</jsp:include>
<!DOCTYPE html>
<html>
    <head>
        <title>오늘 뭐 먹지? - 맛있는 하루의 시작</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search_bar.css">
        <link rel="stylesheet" href="/css/chatbot.css" />

        <script src="/js/chatbot.js"></script>
        <script src="${pageContext.request.contextPath}/js/alarm.js"></script>
        <script>
    document.addEventListener("DOMContentLoaded", function () {

        // 실제 슬라이드는 3장, 앞뒤로 복제본 1장씩 붙어서 총 5개
        const totalSlides = 3;
        let currentIndex = 1;
        let isAnimating = false; // 애니메이션 중 클릭 방지 플래그

        const bannerWrap = document.querySelector(".banner-wrap");
        const slideWrap = document.getElementById("bannerSlide");
        const slideItems = document.querySelectorAll(".slide-item");
        const dots = document.querySelectorAll(".dot");
        const prevBtn = document.querySelector(".prev-btn");
        const nextBtn = document.querySelector(".next-btn");
        let autoSlideInterval;

        // 슬라이드 1개의 너비는 전체 감싸고 있는 wrap의 너비를 기준으로 계산
        function getSlideWidth() {
            return bannerWrap.offsetWidth;
        }

        function moveSlide(index, withTransition) {
            if (withTransition && isAnimating) return;
            if (withTransition) isAnimating = true;

            slideWrap.style.transition = withTransition ? "transform 0.5s ease-in-out" : "none";

            const offset = -index * getSlideWidth();
            slideWrap.style.transform = "translateX(" + offset + "px)";

            if (!withTransition) {
                void slideWrap.offsetWidth; // 리플로우 강제 트리거
                isAnimating = false;
            }
        }

            function goRecipeSearch(keyword) {
                const searchKeyword = keyword ? keyword.trim() : "";

                if (searchKeyword === "") {
                    return;
                }

                const form = document.createElement("form");
                form.method = "post";
                form.action = "${pageContext.request.contextPath}/search_recipe.do";

                const inputSearch = document.createElement("input");
                inputSearch.type = "hidden";
                inputSearch.name = "search";
                inputSearch.value = searchKeyword;

                const inputSelect = document.createElement("input");
                inputSelect.type = "hidden";
                inputSelect.name = "select";
                inputSelect.value = "recipe";

                const inputFromCategory = document.createElement("input");
                inputFromCategory.type = "hidden";
                inputFromCategory.name = "fromCategory";
                inputFromCategory.value = "Y";

                form.appendChild(inputSearch);
                form.appendChild(inputSelect);
                form.appendChild(inputFromCategory);

                document.body.appendChild(form);
                form.submit();
            }
        function updateDots(realIndex) {
            for (let i = 0; i < dots.length; i++) {
                dots[i].classList.remove("active");
            }
            if (dots[realIndex]) {
                dots[realIndex].classList.add("active");
            }
        }

        function getRealIndex() {
            if (currentIndex === 0) return totalSlides - 1;
            if (currentIndex === totalSlides + 1) return 0;
            return currentIndex - 1;
        }

        nextBtn.addEventListener("click", function () {
            if (isAnimating) return;
            currentIndex++;
            moveSlide(currentIndex, true);
            updateDots(getRealIndex());
            resetAutoSlide();
        });

        prevBtn.addEventListener("click", function () {
            if (isAnimating) return;
            currentIndex--;
            moveSlide(currentIndex, true);
            updateDots(getRealIndex());
            resetAutoSlide();
        });

        for (let i = 0; i < dots.length; i++) {
            dots[i].addEventListener("click", function () {
                if (isAnimating) return;
                currentIndex = parseInt(this.getAttribute("data-index")) + 1;
                moveSlide(currentIndex, true);
                updateDots(getRealIndex());
                resetAutoSlide();
            });
        }

        slideWrap.addEventListener("transitionend", function () {
            isAnimating = false;

            if (currentIndex === 0) {
                currentIndex = totalSlides;
                moveSlide(currentIndex, false);
            } else if (currentIndex === totalSlides + 1) {
                currentIndex = 1;
                moveSlide(currentIndex, false);
            }
        });

        function startAutoSlide() {
            autoSlideInterval = setInterval(function () {
                if (isAnimating) return;
                currentIndex++;
                moveSlide(currentIndex, true);
                updateDots(getRealIndex());
            }, 5000);
        }

        function resetAutoSlide() {
            clearInterval(autoSlideInterval);
            startAutoSlide();
        }

        window.addEventListener("resize", function () {
            moveSlide(currentIndex, false);
        });

        // 초기 구동
        moveSlide(currentIndex, false);
        startAutoSlide();

        /*============================ 여기까지 메인배너 슬라이드 관련 함수 =============================*/

        // 오늘의 추천 레시피 자동 변경
        let current = 0;
        const recSlides = document.querySelectorAll(".recommend-slide");

        if (recSlides.length !== 0) {
            setInterval(() => {
                recSlides[current].classList.remove('active');
                current = (current + 1) % recSlides.length;
                recSlides[current].classList.add('active');
            }, 3000);
        }

        // 페이지 로드 시 첫 번째 시즌 탭 초기 세팅
        const initialTab = document.querySelector('.season-tab-item.active');
        changeSeason('봄', initialTab);

    });



    /* ============================  카테고리 키워드 클릭 시 기존 검색 기능처럼 검색되게 하는 함수 ============================ */
    function escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    function goRecipeSearch(keyword) {
        const searchKeyword = keyword ? keyword.trim() : "";

        if (searchKeyword === "") {
            return;
        }

        const searchInput =
            document.querySelector("input[name='search_text']") ||
            document.querySelector("input[name='keyword']") ||
            document.querySelector("input[name='search']");

        if (searchInput) {
            const searchForm = searchInput.closest("form");

            searchInput.value = searchKeyword;

            if (searchForm) {
                searchForm.submit();
                return;
            }
        }
        location.href = "${pageContext.request.contextPath}/recipe_list.do?search_text=" + encodeURIComponent(searchKeyword);
    }

    function selectCategory(category) {
        document.getElementById("categoryModal").style.display = 'flex';
        sideTabCategory(category);
    }

    function openModal() {
        document.getElementById("categoryModal").style.display = 'flex';
        sideTabCategory('상황별추천');
    }

    function closeModal() {
        document.getElementById("categoryModal").style.display = 'none';
        document.getElementById("category-detail").style.display = 'none';
    }

    function closeModalOnOutside(event) {
        const modal = document.getElementById("categoryModal");
        if (event.target === modal) {
            closeModal();
        }
    }

    function handleSidebarClick(event) {
        document.getElementById("category-detail").style.display = 'none';
        document.getElementById("categoryModal").style.display = 'flex';

        const item = event.target.closest('.sidebar-item');
        if (!item) return;

        sideTabCategory(item.dataset.cat);
    }

    function handleSubSidebarClick(event) {
        document.getElementById("category-detail").style.display = 'flex';

        const item = event.target.closest('.sidebar-item');
        if (!item) return;

        openDetailCategory(item.dataset.cat);
    }

    function sideTabCategory(category) {
        const sidebarItems = document.querySelectorAll('.modal-sidebar > div');
        ctg = category;
        sidebarItems.forEach(item => {
            if (item.dataset.cat === category) {
                item.className = "sidebar-item-active";
            } else {
                item.className = "sidebar-item";
            }
        });

        fetch('/category.do?category=' + category)
            .then(res => res.json())
            .then(data => {
                let html = "";

                for (const [subCategoryName, foodList] of Object.entries(data)) {
                    html += "<div class='menu-group'>";
                    html += "<h3>" + subCategoryName + "</h3>";
                    html += "<ul>";

                    let limit = Math.min(foodList.length, 4);

                    for (let i = 0; i < limit; i++) {
                        html += "<li><button type='button' class='category-search-btn' data-keyword='"
                            + escapeHtml(foodList[i])
                            + "' onclick='goRecipeSearch(this.dataset.keyword)'>"
                            + escapeHtml(foodList[i])
                            + "</button></li>";
                    }
                    html += "<li><input type='button' value='더보기 -&gt' onClick='openDetailCategory( \"" + subCategoryName + "\")'></li>";

                    html += "</ul>";
                    html += "</div>";
                }

                document.getElementById("modalCategoryBody").innerHTML = html;

                // 우측 배너 영역
                document.querySelector(".modal-banner-side").innerHTML =
                    "<div class='banner-img-box'>" +
                    "    <img src='/images/main.png' alt='추천 요리' style='width:100%; height:100%; object-fit:cover; border-radius:12px;'>" +
                    "</div>" +
                    "<div class='banner-text-box'>" +
                    "    <h3>오늘 뭐 먹지?</h3>" +
                    "    <p>다양한 레시피로<br>매일 새로운 한 끼를 만나보세요.</p>" +
                    "    <button type='button' class='banner-go-btn' onclick='location.href=\"/recipe_list.do\"'>레시피 둘러보기 &gt;</button>" +
                    "</div>";
            })
            .catch(err => {
                console.error("데이터를 가져오는 도중 에러 발생:", err);

                document.getElementById("modalCategoryBody").innerHTML = "<div style='grid-column: 1/-1; text-align:center; padding:40px; color:#999;'>카테고리 데이터를 불러오지 못했습니다.</div>";
            });
    }

    const openDetailCategory = (subName) => {
        document.getElementById("categoryModal").style.display = 'none';
        document.getElementById("category-detail").style.display = "flex";

        const sidebarItems = document.querySelectorAll('.modal-sidebar > div');

        sidebarItems.forEach(item => {
            if (item.dataset.cat === ctg) {
                item.className = "sidebar-item-active";
            } else {
                item.className = "sidebar-item";
            }
        });

        fetch("/category.do?category=" + ctg)
            .then(res => res.json())
            .then(data => {
                let html = "";
                let mainHtml = "<ul class='main-list'>";
                for (const [subCategoryName, foodList] of Object.entries(data)) {
                    if (subName == subCategoryName) {
                        html += "<div class='sidebar-item-active' data-cat='" + subCategoryName + "'>";
                    } else {
                        html += "<div class='sidebar-item' data-cat='" + subCategoryName + "'>";
                    }

                    html += subCategoryName;
                    html += "</div>";

                    for (let i = 0; i < foodList.length; i++) {
                        if (subName == subCategoryName) {
                            mainHtml += "<li><button type='button' class='category-search-btn' data-keyword='"
                                + escapeHtml(foodList[i])
                                + "' onclick='goRecipeSearch(this.dataset.keyword)'>"
                                + escapeHtml(foodList[i])
                                + "</button></li>";
                        }
                    }

                }
                mainHtml += "</ul>";

                document.getElementById("modal-sidebar2").innerHTML = html;
                document.getElementById("modal-main-banner").innerHTML = mainHtml;

            })
            .catch(err => {
                console.log("Error: " + err);
            })
    }

    /* ============================ 여기까지 카테고리 모달창 관련 함수들 ============================ */

    // 알림(Push) 권한 및 구독 관련
    const applicationServerKey = "BDbjVtJHaSNMMaypEcx2MeXmHvfoWISYWzTCj6Ycc7SoaucH53CzsDGAen6O4ENI9eZMmnilVr9r0F-q3OSbsiM";

    // base64 URL 소스를 Uint8Array로 변환하는 함수 (푸시 서버 인증용 필수 함수)
    function urlB64ToUint8Array(base64String) {
        const padding = '='.repeat((4 - base64String.length % 4) % 4);
        const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/');
        const rawData = window.atob(base64);
        const outputArray = new Uint8Array(rawData.length);
        for (let i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray;
    }

    const member_id = '${sessionScope.user.member_id}';

    // 브라우저가 서비스 워커와 푸시를 지원하는지 확인 후 등록
    if ('serviceWorker' in navigator && 'PushManager' in window && member_id != null && member_id != '') {
        window.addEventListener('load', function () {
            navigator.serviceWorker.register('/js/alarm.js')
                .then(function (registration) {
                    console.log('서비스 워커 등록 성공:', registration);
                    requestNotificationPermission(registration);
                })
                .catch(function (error) {
                    console.error('서비스 워커 등록 실패:', error);
                });
        });
    }

    // 알림 권한 요청 및 구독 처리
    function requestNotificationPermission(registration) {
        Notification.requestPermission().then(function (permission) {
            if (permission === 'granted') {
                console.log('알림 권한 허용됨');
                subscribeUser(registration);
            } else {
                console.warn('알림 권한 거부됨');
            }
        });
    }

    // 푸시 서버(FCM 등)로부터 구독 정보 받아오기
    function subscribeUser(registration) {
        const subscribeOptions = {
            userVisibleOnly: true,
            applicationServerKey: urlB64ToUint8Array(applicationServerKey)
        };

        registration.pushManager.subscribe(subscribeOptions)
            .then(function (subscription) {
                console.log('푸시 구독 성공:', JSON.stringify(subscription));
                sendSubscriptionToServer(subscription);
            })
            .catch(function (error) {
                console.error('푸시 구독 실패:', error);
            });
    }

    // 백엔드(Spring Boot)로 구독 정보 전송
    function sendSubscriptionToServer(subscription) {
        fetch('/api/push/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(subscription)
        })
            .then(res => {
                if (res.ok) console.log('서버에 구독 정보 저장 완료');
            })
            .catch(err => console.error('서버 전송 실패:', err));
    }
    /* ============================ 여기까지 알림 관련 함수들 ============================ */

    function changeSeason(season, el) {
        document.querySelectorAll('.season-tab-item').forEach(function (btn) {
            btn.classList.remove('active');
        });
        if (el) {
            el.classList.add('active');
        }

        // 배너 정보 변경
        fetch('/seasons_banner.do?season=' + encodeURIComponent(season))
            .then(function (res) { return res.json(); })
            .then(function (data) {
                if (data) {
                    document.getElementById('seasonalBannerBadge').textContent = season + ' 추천';
                    document.getElementById('seasonalBannerTitle').textContent = data.banner_title;
                    document.getElementById('seasonalBannerDesc').textContent = data.banner_desc;
                }
            });

        // 음식 카드 목록
        fetch('/seasons_data.do?season=' + encodeURIComponent(season))
            .then(function (res) { return res.json(); })
            .then(function (list) {
                var grid = document.getElementById('seasonalCardGrid');
                grid.innerHTML = '';

                list.forEach(function (item) {
                    var imgHtml = '';
                    if (item.custom_image && item.custom_image !== 'no_image') {
                        imgHtml = '<img src="food_img/' + item.custom_image + '" alt="' + item.food_name + '">';
                    }

                    var card = ''
                        + '<div class="seasonal-card">'
                        + '<span class="card-badge">' + season + ' 메뉴</span>'
                        + '<div class="card-content">'
                        + '<div class="card-info">'
                        + '<h4 class="card-food-name">' + item.food_name + '</h4>'
                        + '<p class="card-food-desc">' + item.sub_desc + '</p>'
                        + '</div>'
                        + '<div class="card-thumb">' + imgHtml + '</div>'
                        + '</div>'
                        + '<a href="/recipe_detail.do?recipe_id=' + item.food_id + '" class="btn-recipe">레시피 둘러보기</a>'
                        + '</div>';

                    grid.innerHTML += card;
                });
            });
    }
</script>
    </head>
    <body>

        <!-- 메인 배너 슬라이드 -->
        <div class="banner-wrap">
            <div class="banner-slide" id="bannerSlide">
                <!-- 마지막 슬라이드 복제 (맨 앞에 배치) -->
                <div class="slide-item">
                    <div class="slide-inner">
                        <img src="${pageContext.request.contextPath}/images/mainbanner3.png" alt="배너3-clone">
                    </div>
                </div>

                <div class="slide-item">
                    <div class="slide-inner">
                        <img src="${pageContext.request.contextPath}/images/mainbanner1.png" alt="배너1">
                        <div class="slide-caption">
                            <span class="slide-badge">메인</span>
                            <h2>냉장고 속 재료로,<br>오늘 한 끼 만들어볼까?</h2>
                            <p>가진 재료를 입력하면 딱 맞는 레시피를 추천해드려요.</p>
                            <a href="/fridge_list.do?member_id=${user.member_id}" class="slide-btn">재료로 레시피 찾기</a>
                        </div>
                    </div>
                </div>

                <div class="slide-item">
                    <div class="slide-inner">
                        <img src="${pageContext.request.contextPath}/images/mainbanner2.png" alt="배너2">
                        <div class="slide-caption">
                            <span class="slide-badge2">추천</span>
                            <h2>오늘의 추천 레시피</h2>
                            <p>상황별, 카테고리별로 원하는 레시피를 찾아보세요</p>
                            <a href="/recipe_list.do" class="slide-btn">레시피 보기</a>
                        </div>
                    </div>
                </div>

                <div class="slide-item">
                    <div class="slide-inner">
                        <img src="${pageContext.request.contextPath}/images/mainbanner3.png" alt="배너3">
                        <div class="slide-caption">
                            <span class="slide-badge3">키친 가이드</span>
                            <h2>요리의 기본,<br>손질부터 보관까지</h2>
                            <p>재료 손질법, 보관법, 요리 꿀팁을 한 눈에 모았어요</p>
                            <a href="/guide_list.do" class="slide-btn">가이드 보러가기</a>
                        </div>
                    </div>
                </div>

                <!-- 첫 번째 슬라이드 복제 (맨 뒤에 배치) -->
                <div class="slide-item">
                    <div class="slide-inner">
                        <img src="${pageContext.request.contextPath}/images/mainbanner1.png" alt="배너1-clone">
                    </div>
                </div>
            </div>

            <button type="button" class="banner-btn prev-btn">&#10094;</button>
            <button type="button" class="banner-btn next-btn">&#10095;</button>

            <div class="banner-indicator">
                <span class="dot active" data-index="0"></span>
                <span class="dot" data-index="1"></span>
                <span class="dot" data-index="2"></span>
            </div>
        </div>






        <div class="container main-page">
            <div class="category-list">
                <button type="button" class="category-item" data-category="korean" onclick="selectCategory('한식')">
                    <div class="category-icon">🍚</div>한식
                </button>
                <button type="button" class="category-item" data-category="western" onclick="selectCategory('양식')">
                    <div class="category-icon">🍝</div>양식
                </button>
                <button type="button" class="category-item" data-category="chinese" onclick="selectCategory('중식')">
                    <div class="category-icon">🍳</div>중식
                </button>
                <button type="button" class="category-item" data-category="japanese" onclick="selectCategory('일식')">
                    <div class="category-icon">🍣</div>일식
                </button>
                <button type="button" class="category-item" data-category="asian" onclick="selectCategory('아시안')">
                    <div class="category-icon">🌏</div>아시안
                </button>
                <button type="button" class="category-item" data-category="diet" onclick="selectCategory('건강식/다이어트')">
                    <div class="category-icon">🌿</div>건강식/다이어트
                </button>
                <button type="button" class="category-item" data-category="easy" onclick="selectCategory('초간단요리')">
                    <div class="category-icon">⏱️</div>초간단요리
                </button>
                <button type="button" class="category-item" data-category="dessert" onclick="selectCategory('디저트')">
                    <div class="category-icon">🍰</div>디저트
                </button>
                <button type="button" class="category-item" data-category="baking" onclick="selectCategory('베이킹')">
                    <div class="category-icon">🍞</div>베이킹
                </button>
                <button type="button" class="category-item" id="btnAllCategory" onclick="openModal()">
                    <div class="category-icon">☰</div>전체보기
                </button>
            </div>
        </div>

        <div class="container main-page">
            <div class="seasonal-header">
                <span class="seasonal-badge">조회수 TOP5</span>
                <h2 class="seasonal-title">이달의 TOP 5 인기 요리</h2>
                <p class="seasonal-subtitle">조회수로 검증된 베스트 레시피를 확인해보세요</p>
            </div>

            <div class="recipe-grid">
                <c:forEach var="recipe" items="${view_recipes}" varStatus="status">
                    <div class="recipe-card">
                        <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}">
                            <div class="recipe-img">
                                <img src="${pageContext.request.contextPath}/images/${recipe.thumbnail}"/>
                            </div>
                            <div class="rank-badge">${status.index + 1}</div>
                            <div class="recipe-info">
                                <div class="recipe-name">${recipe.title}</div>
                                <div class="recipe-author">👤 ${recipe.nickname}</div>
                                <div class="recipe-meta"><span class="star-rating">★ 4.8</span><span>조회수 <fmt:formatNumber value="${recipe.view_count}"/> </span></div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <div class="container main-page mid-sections">
        <div class="mid-box refrigerator-box">
            <div>
                <br/>
                <h3>냉장고 재료로<br>레시피 추천받기</h3>
                <p>집에 있는 재료를 선택하면<br>만들 수 있는 요리를 추천해드려요!</p>
            </div>
            <button class="ref-btn" onClick="location.href='/fridge_list.do?member_id=${sessionScope.user.member_id}'">재료 선택하기 &rarr;</button>
        </div>

        <div class="mid-box">
            <h3 class="box-title">오늘의 추천 레시피</h3>
            <div class="today-main">
                <c:forEach var="recipe" items="${recommend}" varStatus="status">
                    <div class="recommend-slide ${status.first ? 'active' : ''}" onclick="location.href='/recipe_detail.do?recipe_id=${recipe.recipe_id}'">
                        <div class="today-main-img">
                            <img src="/upload/recipe/${recipe.thumbnail}"/>
                        </div>
                        <div class="today-main-info">
                            <h4>${recipe.title}</h4>
                            <p>이런 메뉴는 어떠신가요?</p>
                            <span class="author">👤 ${recipe.nickname}</span>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- 이미지 작게 5개 나오는 자리 -->
            <div class="today-sub-list">
                <div class="today-sub-thumb"></div>
                <div class="today-sub-thumb"></div>
                <div class="today-sub-thumb"></div>
                <div class="today-sub-thumb"></div>
                <div class="today-sub-thumb"></div>
            </div>
        </div>
    </div>

    <div class="container main-page">
        <div class="seasonal-header">
            <span class="seasonal-badge">계절별 추천</span>
            <h2 class="seasonal-title">계절의 맛을 담은 이달의 추천 요리</h2>
            <p class="seasonal-subtitle">제철 재료로 만드는 특별한 레시피, 사계절의 맛도 둘러보세요</p>
        </div>

        <div class="seasonal-banner">
            <span class="banner-badge" id="seasonalBannerBadge">봄 추천</span>
            <h3 class="banner-title" id="seasonalBannerTitle">산뜻하게 시작하는 봄 제철요리</h3>
            <p class="banner-desc" id="seasonalBannerDesc">향긋한 채소와 가벼운 식감이 살아 있는 봄 메뉴를 모았습니다.</p>
        </div>

        <div class="seasonal-tabs">
            <button type="button" class="season-tab-item active" onclick="changeSeason('봄', this)">봄</button>
            <button type="button" class="season-tab-item" onclick="changeSeason('여름', this)">여름</button>
            <button type="button" class="season-tab-item" onclick="changeSeason('가을', this)">가을</button>
            <button type="button" class="season-tab-item" onclick="changeSeason('겨울', this)">겨울</button>
        </div>

        <div class="seasonal-card-grid" id="seasonalCardGrid"></div>
    </div>

    <div class="info-bar">
        <div class="info-item">🍳 <span>쉽고 간단한 레시피<br><small>누구나 따라할 수 있어요</small></span></div>
        <div class="info-item">🍱 <span>다양한 카테고리<br><small>원하는 메뉴를 쉽게 찾아보세요</small></span></div>
        <div class="info-item">🥕 <span>냉장고 재료 활용<br><small>남은 재료로 알뜰하게 요리해요</small></span></div>
        <div class="info-item">💬 <span>요리로 소통해요<br><small>후기와 팁을 공유해보세요</small></span></div>
    </div>

    <!-- footer 회사 정보 jsp 파일 include -->
    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

    <!-- 챗봇 -->
    <jsp:include page="/WEB-INF/views/chatbot/chatbot_main.jsp" />

    <!-- 메인배너 밑 카테고리 중 전체보기 클릭 시 보여질 블럭 -->
    <div id="categoryModal" class="modal-overlay" onclick="closeModalOnOutside(event)">
        <div class="modal-content">
            <button type="button" class="modal-close-btn" onclick="closeModal()">×</button>

            <div class="modal-body">
                <div class="modal-sidebar" onclick="handleSidebarClick(event)">
                    <div class="sidebar-item-active" data-cat="상황별추천" id="1">⭐ 상황별 추천</div>
                    <div class="sidebar-item" data-cat="한식" id="2">🍚 한식</div>
                    <div class="sidebar-item" data-cat="양식" id="3">🍝 양식</div>
                    <div class="sidebar-item" data-cat="중식" id="4">🍳 중식</div>
                    <div class="sidebar-item" data-cat="일식" id="5">🍣 일식</div>
                    <div class="sidebar-item" data-cat="아시안" id="6">🌏 아시안</div>
                    <div class="sidebar-item" data-cat="건강식/다이어트" id="7">🌿 건강식/다이어트</div>
                    <div class="sidebar-item" data-cat="초간단요리" id="8">⏱️ 초간단요리</div>
                    <div class="sidebar-item" data-cat="디저트" id="9">🍰 디저트</div>
                    <div class="sidebar-item" data-cat="베이킹" id="10">🍞 베이킹</div>
                    <div class="sidebar-item" data-cat="음료/차" id="11">☕ 음료/차</div>
                </div>

                <div class="modal-main">
                    <div id="modalCategoryBody" class="category-grid-wrapper"></div>
                </div>

                <div class="modal-banner-side">
                </div>
            </div>
        </div>
    </div>

    <!-- 카테고리에서 상세보기로 보여줄 블럭 -->
    <div class="modal-overlay" id="category-detail">
        <div class="modal-content">
            <button type="button" class="modal-close-btn" onclick="closeModal()">×</button>

            <div class="modal-body">
                <div class="modal-sidebar" onclick="handleSidebarClick(event)">
                    <div class="sidebar-item" data-cat="상황별추천" id="1">⭐ 상황별 추천</div>
                    <div class="sidebar-item" data-cat="한식" id="2">🍚 한식</div>
                    <div class="sidebar-item" data-cat="양식" id="3">🍝 양식</div>
                    <div class="sidebar-item" data-cat="중식" id="4">🍳 중식</div>
                    <div class="sidebar-item" data-cat="일식" id="5">🍣 일식</div>
                    <div class="sidebar-item" data-cat="아시안" id="6">🌏 아시안</div>
                    <div class="sidebar-item" data-cat="건강식/다이어트" id="7">🌿 건강식/다이어트</div>
                    <div class="sidebar-item" data-cat="초간단요리" id="8">⏱️ 초간단요리</div>
                    <div class="sidebar-item" data-cat="디저트" id="9">🍰 디저트</div>
                    <div class="sidebar-item" data-cat="베이킹" id="10">🍞 베이킹</div>
                    <div class="sidebar-item" data-cat="음료/차" id="11">☕ 음료/차</div>
                </div>

                <div class="modal-sidebar2" id="modal-sidebar2" onClick="handleSubSidebarClick(event)">
                    <!-- 여기에서 중분류만 보여줌 -->

                </div>

                <div class="modal-main-banner" id="modal-main-banner">
                    <!-- 여기에 음식이름 전부 보여주기 -->
                </div>

                <div class="modal-banner-side">
                    <div class='banner-img-box'>
                        <img src='/images/main.png' alt='추천 요리' style='width:100%; height:100%; object-fit:cover; border-radius:12px;'>gap
                    </div>
                    <div class='banner-text-box'>
                        <h3>오늘 뭐 먹지?</h3>
                        <p>다양한 레시피로<br>매일 새로운 한 끼를 만나보세요.</p>
                        <button type='button' class='banner-go-btn' onclick='location.href="/recipe_list.do"'>레시피 둘러보기 &gt;</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>