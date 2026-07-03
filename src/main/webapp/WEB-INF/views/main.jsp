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
            document.addEventListener('DOMContentLoaded', function () {
                
                const track = document.getElementById('bannerTrack');
                const slides = Array.from(track.children);
                const dotsWrap = document.getElementById('bannerDots');
                const prevBtn = document.getElementById('prevBtn');
                const nextBtn = document.getElementById('nextBtn');

                const slideWidthPercent = 100; 
                let currentIndex = 1;         // 앞에 clone 1개 붙일 것이므로 실제 첫 슬라이드는 index 1
                let autoSlideTimer = null;

                // 1) 앞뒤에 클론 슬라이드 추가 (무한 루프용)
                const firstClone = slides[0].cloneNode(true);
                const lastClone = slides[slides.length - 1].cloneNode(true);
                track.appendChild(firstClone);
                track.insertBefore(lastClone, slides[0]);

                const allSlides = Array.from(track.children);

                // 2) 점(dot) 인디케이터 생성 (원본 개수만큼)
                slides.forEach((_, i) => {
                    const dot = document.createElement('span');
                    if (i === 0) dot.classList.add('active');
                    dot.addEventListener('click', () => goToSlide(i + 1));
                    dotsWrap.appendChild(dot);
                });
                const dots = Array.from(dotsWrap.children);

                // 3) 트랙 위치 이동 함수
                function updateTrackPosition(withTransition = true) {
                    track.style.transition = withTransition ? 'transform 0.5s ease-in-out' : 'none';
                    const offset = -(currentIndex * slideWidthPercent);
                    track.style.transform = `translateX(${offset}%)`;

                    // 활성 슬라이드 표시
                    allSlides.forEach(s => s.classList.remove('active'));
                    allSlides[currentIndex].classList.add('active');

                    // 도트 갱신
                    const realIndex = getRealIndex();
                    dots.forEach(d => d.classList.remove('active'));
                    dots[realIndex].classList.add('active');
                }

                function getRealIndex() {
                    if (currentIndex === 0) return slides.length - 1;
                    if (currentIndex === allSlides.length - 1) return 0;
                    return currentIndex - 1;
                }

                function goToSlide(index) {
                    currentIndex = index;
                    updateTrackPosition();
                }

                function nextSlide() {
                    currentIndex++;
                    updateTrackPosition();
                }

                function prevSlide() {
                    currentIndex--;
                    updateTrackPosition();
                }

                // 4) 클론으로 넘어갔을 때 transition 끝나면 순간이동으로 슬라이드처럼 보이게
                track.addEventListener('transitionend', () => {
                    if (currentIndex === 0) {
                        currentIndex = slides.length;
                        updateTrackPosition(false);
                    } else if (currentIndex === allSlides.length - 1) {
                        currentIndex = 1;
                        updateTrackPosition(false);
                    }
                });

                // 5) 자동 슬라이드 (3초)
                function startAutoSlide() {
                    autoSlideTimer = setInterval(nextSlide, 3000);
                }
                function stopAutoSlide() {
                    clearInterval(autoSlideTimer);
                }

                // 버튼 클릭 시 수동 이동 + 타이머 리셋
                nextBtn.addEventListener('click', () => { nextSlide(); stopAutoSlide(); startAutoSlide(); });
                prevBtn.addEventListener('click', () => { prevSlide(); stopAutoSlide(); startAutoSlide(); });

                // 마우스 올리면 잠깐 멈추기 
                track.addEventListener('mouseenter', stopAutoSlide);
                track.addEventListener('mouseleave', startAutoSlide);

                // 초기화
                updateTrackPosition(false);
                startAutoSlide();
                let current = 0;
                const slides = document.querySelectorAll(".recommend-slide");

                if (slides.length === 0) {
                    return;
                }

                setInterval(() => {
                    slides[current].classList.remove('active');
            
                    current = (current + 1) % slides.length;
            
                    slides[current].classList.add('active');
                }, 3000);
                changeSeason('봄', document.querySelector('.season-tab-item.active'));
            });
            /*============================ 여기까지 메인배너 슬라이드 관련 함수 =============================*/
            /* ============================ 여기부터 카테고리 모달창 관련 함수들 ============================ */
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
                    //  모달에서 누른 음식명을 검색창 검색어처럼 사용
                    const searchKeyword = keyword ? keyword.trim() : "";

                    if (searchKeyword === "") {
                        return;
                    }

                    //  navibar.jsp 안에 있는 검색 input을 찾아서 기존 검색 form을 그대로 submit
                    // input name이 search_text / keyword / search 중 하나여도 동작하게 처리
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

                    //  혹시 검색 form을 못 찾았을 때만 사용하는 예비 이동 코드
                    // 검색창 form이 정상적으로 있으면 위에서 submit되므로 이 부분은 거의 실행되지 않음
                    location.href = "${pageContext.request.contextPath}/recipe_list.do?search_text=" + encodeURIComponent(searchKeyword);
                }

                // 선택한 카테고리들 열기
                function selectCategory(category){
                    document.getElementById("categoryModal").style.display = 'flex';
                    sideTabCategory(category);
                }
                
                // 전체보기 모달 열기 (열릴 때 자동으로 첫 번째 카테고리 '상황별추천')
                function openModal(){
                    document.getElementById("categoryModal").style.display = 'flex';
                    sideTabCategory('상황별추천');
                }
                
                // 전체보기 모달 닫기
                function closeModal(){
                    document.getElementById("categoryModal").style.display = 'none';
                    document.getElementById("category-detail").style.display = 'none';
                }
                
                // 메뉴창 바깥 영역 클릭 시 닫히게 하기
                function closeModalOnOutside(event) {
                    const modal = document.getElementById("categoryModal");
                    if (event.target === modal) {
                        closeModal();
                    }
                }
                
                //왼쪽 중분류 사이드바 클릭 감지
                function handleSidebarClick(event) {
                    document.getElementById("category-detail").style.display = 'none';
                    document.getElementById("categoryModal").style.display = 'flex';
                    
                    const item = event.target.closest('.sidebar-item'); // item = 클릭된 <div> 태그 자체
                    if (!item) return; // sidebar-item을 클릭한 게 아니면 무시
                    
                    // 카테고리명(data-cat 값) 전달
                    sideTabCategory(item.dataset.cat);
                }
                
                function handleSubSidebarClick(event) {
                    document.getElementById("category-detail").style.display = 'flex';
                    
                    const item = event.target.closest('.sidebar-item'); // item = 클릭된 <div> 태그 자체
                    if (!item) return; // sidebar-item을 클릭한 게 아니면 무시
                    
                    // 카테고리명(data-cat 값) 전달
                    openDetailCategory(item.dataset.cat);
                }
                
                let ctg = "none";
                
                // 카테고리 변경 및 스타일 적용 함수
                function sideTabCategory(category) {
                    const sidebarItems = document.querySelectorAll('.modal-sidebar > div');
                    ctg = category;
                    sidebarItems.forEach(item => {
                        if(item.dataset.cat === category) {
                            item.className = "sidebar-item-active"; // 누른 것만 활성화
                        } else {
                            item.className = "sidebar-item"; // 나머지는 기본 스타일
                        }
                    });
                    
                    fetch('/category.do?category=' + category)
                    .then(res => res.json())
                    .then(data => {
                        let html = "";
                        
                        for(const[subCategoryName, foodList] of Object.entries(data)){
                            html += "<div class='menu-group'>";
                            html += "<h3>" + subCategoryName + "</h3>";
                            html += "<ul>";
                            
                            let limit = Math.min(foodList.length, 4);
                            
                            for(let i=0 ; i<limit ; i++){
                                // 기존처럼 URL을 직접 박는 방식이 아니라, 검색창 검색 기능을 재사용하도록 변경
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
                        "    <img src='/images/main.png' alt='추천 요리' style='width:100%; height:100%; object-fit:cover; border-radius:12px;'> gap" +
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
                        if(item.dataset.cat === ctg) {
                            item.className = "sidebar-item-active"; // 누른 것만 활성화
                        } else {
                            item.className = "sidebar-item"; // 나머지는 기본 스타일
                        }
                    });
                    
                    fetch("/category.do?category=" + ctg)
                    .then(res => res.json())
                    .then(data => {
                        let html = "";
                        let mainHtml = "<ul class='main-list'>";
                        for(const[subCategoryName, foodList] of Object.entries(data)){
                            if(subName == subCategoryName){
                                html += "<div class='sidebar-item-active' data-cat='" + subCategoryName + "'>";
                            }else{
                                html += "<div class='sidebar-item' data-cat='" + subCategoryName + "'>";
                            }
                            
                            html += subCategoryName;
                            html += "</div>";
                            
                            for(let i=0 ; i<foodList.length ; i++){
                                if(subName == subCategoryName){
                                    // 상세보기 모달의 음식명도 클릭하면 검색 기능처럼 동작하도록 변경
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
                // 2. 브라우저가 서비스 워커와 푸시를 지원하는지 확인 후 등록
                if ('serviceWorker' in navigator && 'PushManager' in window && member_id != null && member_id != '') {
                    window.addEventListener('load', function() {
                        navigator.serviceWorker.register('/js/alarm.js')
                        .then(function(registration) {
                            console.log('서비스 워커 등록 성공:', registration);
                            
                            // 등록 성공 후 사용자에게 권한 요청 및 구독 진행
                            requestNotificationPermission(registration);
                        })
                        .catch(function(error) {
                            console.error('서비스 워커 등록 실패:', error);
                        });
                    });
                }
                
                // 3. 알림 권한 요청 및 구독 처리
                function requestNotificationPermission(registration) {
                    Notification.requestPermission().then(function(permission) {
                        if (permission === 'granted') {
                            console.log('알림 권한 허용됨');
                            subscribeUser(registration);
                        } else {
                            console.warn('알림 권한 거부됨');
                        }
                    });
                }
                
                // 4. 푸시 서버(FCM 등)로부터 구독 정보 받아오기
                function subscribeUser(registration) {
                    const subscribeOptions = {
                        userVisibleOnly: true,
                        applicationServerKey: urlB64ToUint8Array(applicationServerKey)
                    };
                    
                    registration.pushManager.subscribe(subscribeOptions)
                    .then(function(subscription) {
                        console.log('푸시 구독 성공:', JSON.stringify(subscription));
                        
                        // 5. 이 subscription 객체를 DB에 저장하기 위해 백엔드로 전송해야 해!
                        sendSubscriptionToServer(subscription);
                    })
                    .catch(function(error) {
                        console.error('푸시 구독 실패:', error);
                    });
                }
                
                // 6. 백엔드(Spring Boot)로 구독 정보 전송 (Ajax)
                function sendSubscriptionToServer(subscription) {
                    // 여기에 Fetch API나 jQuery Ajax를 써서 Spring Boot 컨트롤러로 던져주면 돼.
                    fetch('/api/push/register', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(subscription)
                    })
                    .then(res => {
                        if(res.ok) console.log('서버에 구독 정보 저장 완료');
                    })
                    .catch(err => console.error('서버 전송 실패:', err));
                }
            /* ============================ 여기까지 알림 관련 함수들 ============================ */
            function changeSeason(season, el) {
                // 탭 active 변경
                document.querySelectorAll('.season-tab-item').forEach(function(btn) {
                    btn.classList.remove('active');
                });
                if (el) {
                    el.classList.add('active');
                }

                // 배너 정보 변경
                fetch('/seasons_banner.do?season=' + encodeURIComponent(season))
                    .then(function(res) { return res.json(); })
                    .then(function(data) {
                        if (data) {
                            document.getElementById('seasonalBannerBadge').textContent = season + ' 추천';
                            document.getElementById('seasonalBannerTitle').textContent = data.banner_title;
                            document.getElementById('seasonalBannerDesc').textContent = data.banner_desc;
                        }
                    });

                // 음식 카드 목록 
                fetch('/seasons_data.do?season=' + encodeURIComponent(season))
                    .then(function(res) { return res.json(); })
                    .then(function(list) {
                        var grid = document.getElementById('seasonalCardGrid');
                        grid.innerHTML = '';

                        list.forEach(function(item) {
                            var imgHtml = '';
                            if (item.custom_image && item.custom_image !== 'no_image') {
                                imgHtml = '<img src="food_img/' + item.custom_image + '" alt="' + item.food_name + '">';
                            }

                            var card = ''
                                + '<div class="seasonal-card">'
                                +   '<span class="card-badge">' + season + ' 메뉴</span>'
                                +   '<div class="card-content">'
                                +     '<div class="card-info">'
                                +       '<h4 class="card-food-name">' + item.food_name + '</h4>'
                                +       '<p class="card-food-desc">' + item.sub_desc + '</p>'
                                +     '</div>'
                                +     '<div class="card-thumb">' + imgHtml + '</div>'
                                +   '</div>'
                                +   '<a href="/recipe_detail.do?recipe_id=' + item.food_id + '" class="btn-recipe">레시피 둘러보기</a>'
                                + '</div>';

                            grid.innerHTML += card;
                        });
                    });
            }
            /* ============================ 여기까지 계절별 메뉴 추천 관련 함수들 ============================ */
        </script>
    </head>
    <body>

        <!-- 메인 배너 -->
        <div class="banner-wrap">
            <button class="banner-btn prev" id="prevBtn">&#10094;</button>

            <div class="banner-viewport">
                <ul class="banner-track" id="bannerTrack">
                    <li class="banner-slide">
                        <img src="${pageContext.request.contextPath}/images/mainbanner1.png" alt="배너1">
                    </li>
                    <li class="banner-slide">
                        <img src="${pageContext.request.contextPath}/images/mainbanner2.png" alt="배너2">
                    </li>
                    <li class="banner-slide">
                        <img src="${pageContext.request.contextPath}/images/mainbanner3.png" alt="배너3">
                    </li>
                </ul>
            </div>
            <button class="banner-btn next" id="nextBtn">&#10095;</button>

            <div class="banner-dots" id="bannerDots"></div>
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