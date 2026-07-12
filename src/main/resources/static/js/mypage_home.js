//const applicationServerKey = "BDbjVtJHaSNMMaypEcx2MeXmHvfoWISYWzTCj6Ycc7SoaucH53CzsDGAen6O4ENI9eZMmnilVr9r0F-q3OSbsiM";

// 마이페이지 홈진입시 최근 레시피 탭을 기본으로 표시
window.onload = function(){
    btn_change("recipe");

}

// 최근 활동 내역 전환, 더보기 버튼 이동 경로 현재 탭으로 설정
function btn_change(type) {
    const boxes = ["recipe", "comment", "bookmark"];
    let see_btn = document.getElementById("see-btn");
    
    boxes.forEach( name => {
        const box = document.getElementById(name+"box");
        if(box){
            box.style.display = name == type ? "block" : "none";
        }
    });

    document.querySelectorAll(".home-tab-btn").forEach(tab => {
        tab.classList.remove("active");
    });

    const tabs = document.querySelectorAll(".home-tab-btn");
    const activeTab = tabs[boxes.indexOf(type)];

    if( activeTab ) {
        activeTab.classList.add("active");
    }

    if (see_btn) {
        see_btn.onclick = () => location.href= "/mypage.do?menu=" +type;
    }
    

}



