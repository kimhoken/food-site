<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <section class="admin-home">

            <div class="admin-title-box">
                <h2>
                    관리자 대시보드
                </h2>
                <p>안녕하세요! ${profileuser.nickname}님! 오늘도 맛있는 하루되세요!</p>
            </div>

            <div class="summary-grid">

                <div class="summary-card green">
                    <p>전체 회원 수</p>
                    <strong>${userTotal}</strong>
                    <span>인원수</span>
                </div>

                <div class="summary-card orange">
                    <p>전체 레시피</p>
                    <strong>${recipeTotal}</strong>
                    <span>레시피 건수</span>
                </div>

                <div class="summary-card blue">
                    <p>문의대기</p>
                    <strong>${inquiryTotal}</strong>
                    <span> 건수</span>
                </div>

                <div class="summary-card red">
                    <p>신고 대기</p>
                    <strong>${reportTotal}</strong>
                    <span>건수</span>
                </div>

            </div>

        </section>

        <section class="admin-content-grid">

            <div class="recent-recipe-box">

                <div class="box-title">
                    <h3>최근 등록 레시피</h3>
                    <span onclick="location.href='/admin/recipe'">더보기</span>
                </div>

                <table class="admin-table">
                    <tr>
                        <th>번호</th>
                        <th>제목</th>
                        <th>작성자</th>
                        <th>등록일</th>
                        <th>상태</th>
                    </tr>
                    <!-- forEach로 최근 등록된 레시피 출력  -->
                    <c:forEach var="recipe" items="${list}">

                        <tr onclick="location.href='recipe_detail.do?recipe_id=${recipe.recipe_id}'">

                            <td>${recipe.rank_num}</td>
                            <td>
                                <img src="/upload/recipe/${recipe.thumbnail}" width="85px" height="85px"/>
                                <p>${recipe.title}</p>
                            </td>
                            <td>${recipe.nickname}</td>
                            <td>${recipe.created_date}</td>
                            <td>
                                <c:if test="${recipe.status eq 'ACTIVE'}">
                                    공개
                                </c:if>

                                <c:if test="${recipe.status eq 'HIDDEN'}">
                                    비공개
                                </c:if>

                                <c:if test="${recipe.status eq 'DELETE'}">
                                    삭제
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <!--  -->
                </table>

            </div>

            <div class="quick-box">

                <h3>빠른 관리</h3>
                <div class="quick-menu">

                    <a href="/admin/member">회원 관리
                        <small>회원 목록 및 관리</small>
                    </a>

                    <a href="/admin/recipe">레시피 관리
                        <small>레시피 등록 및 관리</small>
                    </a>

                    <a href="/admin/inquiry">문의 관리
                        <small> 문의 확인 및 답변</small>
                    </a>

                    <a href="/report/admin/list.do">신고 관리
                        <small>신고 확인 및 처리</small>
                    </a>

                </div>

                <div class="admin-alert-box">
                    <h4>운영 알림</h4>
                    <p>답변 대기 문의 <strong>${inquiryTotal}건</strong></p>
                    <p>처리 대기 신고 <strong>${reportTotal}건</strong></p>
                </div>
                
            </div>
        </section>