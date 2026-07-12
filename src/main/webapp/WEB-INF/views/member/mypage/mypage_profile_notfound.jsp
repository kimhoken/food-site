<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="profile-empty-state profile-notfound">
    <div class="profile-empty-icon">!</div>
    <h3>회원 정보를 찾을 수 없습니다.</h3>
    <p>존재하지 않거나 접근할 수 없는 회원 프로필입니다.</p>
    <input type="button" value="메인으로 이동" onclick="location.href='/main_list.do'" />
</section>
