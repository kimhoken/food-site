<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <head>
        <script src="/js/mypage_home.js"></script>
    </head>

    <body>
        <section class="home-page">
            <div class="home-grid">
                <div class="home-activity-box">
                    <div class="box-header">
                        <h3> 내활동</h3>
                    </div>

                    <div class="home-activity-tab">

                        <span class="home-tab-btn ${param.menu eq 'recipe' ? 'active' : ''}"
                                onclick="btn_change('recipe')">레시피</span>
                        <span class="home-tab-btn ${param.menu eq 'cooment' ? 'active' : ''}" 
                                onclick="btn_change('comment')">댓글</span>
                        <span class="home-tab-btn ${param.menu eq 'bookmark' ? 'active' : ''}" 
                                onclick="btn_change('bookmark')">북마크</span>

                    </div>
                    <div id="recipebox" class="home-activity-list">
                        <h3>최근 작성 레시피</h3>
                        <!-- forEach로 레시피 5개, 댓글 5개 출력 -->
                        <c:forEach var="recipe" items="${recentlyRecipeList}">
                            <a href="/recipe_detail.do?recipe_id=${recipe.recipe_id}" class="home-activity-item">

                                <div class="home-item-inner">
                                    <img class="home-item-img" src="/upload/recipe/${recipe.thumbnail}" />
                                    <strong class="home-item-title">${recipe.title}</strong>
                                    <small class="home-item-date">${recipe.created_date}</small>
                                </div>

                            </a>
                        </c:forEach>
                        
                    </div>
                    
                    <div id="commentbox" class="home-activity-list">
                        <h3>최근 작성된 댓글</h3>
                        <!-- forEach로 레시피 5개, 댓글 5개 출력 -->
                        <c:forEach var="comment" items="${commentList}">

                            <a href="/recipe_detail.do?recipe_id=${comment.recipe_id}" class="home-activity-item">

                                <div class="home-item-inner">
                                    <img class="home-item-img" src="/upload/recipe/${comment.thumbnail}" />
                                    <strong class="home-item-title">${comment.content}</strong>
                                    <small class="home-item-date">${comment.created_date}</small>
                                </div>

                            </a>

                        </c:forEach>
                        
                    </div>

                    <div id="bookmarkbox" class="home-activity-list">

                        <h3>북마크</h3>
                        <!-- forEach로 레시피 5개, 댓글 5개 출력 -->
                        <c:forEach var="bookmark" items="${bookmarkList}">

                            <a href="/recipe_detail.do?recipe_id=${bookmark.recipe_id}" class="home-activity-item">

                                <div class="home-item-inner">
                                    <img class="home-item-img" src="/upload/recipe/${bookmark.thumbnail}" />
                                    <strong class="home-item-title">${bookmark.title}</strong>
                                    <small class="home-item-date">${bookmark.created_date}</small>
                                </div>

                            </a>

                        </c:forEach>
                        
                    </div>

                    <input id="see-btn" class="home-more-btn"
                            type="button" value="더보기" onclick="" />
                </div>

                <div class="home-history-box">
                    <!-- 활동 내역 출력을 최근순 5개 출력하게 세팅 예정  -->
                    <h3>최근 활동 내역</h3>
                    
                    <c:forEach var="activity" items="${activity}">

                        <div class="home-history-item">
                            ${activity.activity_title} 
                            <span class="home-activity-date">${activity.created_date}</span>
                        </div>

                    </c:forEach>
                    
                </div>
                
            </div>
            
        </section>
    </body>

       