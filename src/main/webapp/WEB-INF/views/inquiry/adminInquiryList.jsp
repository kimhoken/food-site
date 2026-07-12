<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="/css/adminInquiryList.css">
    </head>

    <body>

    <div class="inquiry-list-page">

        <div class="inquiry-list-wrap">

            <div class="inquiry-title-box">
                <h2>문의 관리</h2>
                <p>회원 및 비회원 문의 내역을 확인하고 답변을 관리합니다.</p>
            </div>

            <!-- 답변 상태, 정렬, 문의 유형을 기준으로 목록 필터링 -->
            <form action="/admin/inquiry" method="get" class="inquiry-filter-box">

                <div class="filter-left">

                    <button type="submit" name="status" value="n"
                            class="status-filter-btn wait-btn ${status eq 'n' ? 'active' : ''}">
                        답변대기
                    </button>

                    <button type="submit" name="status" value="y"
                            class="status-filter-btn complete-btn ${status eq 'y' ? 'active' : ''}">
                        답변완료
                    </button>

                </div>

                <div class="filter-right">

                    <select name="sort" class="filter-select" onchange="this.form.submit()">
                        <option value="">정렬</option>
                        <option value="latest" ${sort eq 'latest' ? 'selected' : ''}>최신순</option>
                        <option value="oldest" ${sort eq 'oldest' ? 'selected' : ''}>오래된순</option>
                        <option value="title" ${sort eq 'title' ? 'selected' : ''}>제목순</option>
                    </select>

                    <select name="type" class="filter-select" onchange="this.form.submit()">
                        <option value="">유형</option>
                        <option value="계정" ${type eq '계정' ? 'selected' : ''}>계정</option>
                        <option value="레시피 문의" ${type eq '레시피 문의' ? 'selected' : ''}>레시피 문의</option>
                        <option value="서비스 이용 문의" ${type eq '서비스 이용 문의' ? 'selected' : ''}>서비스 이용 문의</option>
                        <option value="기타" ${type eq '기타' ? 'selected' : ''}>기타</option>
                    </select>

                    <a href="/admin/inquiry" class="reset-filter-btn">↻</a>
                </div>

            </form>

            <table class="inquiry-list-table">
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>유형</th>
                        <th>제목</th>
                        <th>작성자</th>
                        <th>작성일</th>
                        <th>상태</th>
                    </tr>
                </thead>

                <tbody>
                    <c:forEach var="vo" items="${list}">
                        <tr>
                            <td>${vo.inquiry_id}</td>
                            <td>${vo.type}</td>

                            <td class="title-cell">
                                <a href="/inquiry/admin/detail?inquiry_id=${vo.inquiry_id}">
                                    ${vo.title}
                                </a>
                            </td>

                            <!-- 회원 문의와 비회원 문의의 작성자 표시 구분 -->
                            <td>
                                <c:choose>
                                    <c:when test="${not empty vo.member_id}">
                                        ${vo.nickname}
                                    </c:when>
                                    <c:otherwise>
                                        비회원
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td>
                                <fmt:formatDate value="${vo.created_date}" pattern="yyyy-MM-dd"/>
                            </td>

                            <!-- 문의 처리 상태에 따라 다른 상태 배지 표시 -->
                            <td>
                                <c:choose>
                                    <c:when test="${vo.status eq 'y'}">
                                        <span class="status-complete">답변완료</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-wait">답변대기</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="list-bottom-box">

                <div class="inquiry-total-count">
                    전체 ${totalcount}건
                </div>

                <!-- 페이지 이동 시 현재 필터와 정렬 조건 유지 -->
                <div class="paging-box">


                    <a href="/admin/inquiry?page=${paging.page - 1}&status=${status}&sort=${sort}&type=${type}">◀</a>

                    <c:forEach var="i" begin="${paging.startpage}" end="${paging.endpage}">
                        <c:choose>
                            <c:when test="${i == paging.page}">
                                <strong>${i}</strong>
                            </c:when>
                            <c:otherwise>
                                <a href="/admin/inquiry?page=${i}&status=${status}&sort=${sort}&type=${type}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <a href="/admin/inquiry?page=${paging.page + 1}&status=${status}&sort=${sort}&type=${type}">▶</a>
                

                </div>
            </div>

        </div>

    </div>

    </body>
</html>