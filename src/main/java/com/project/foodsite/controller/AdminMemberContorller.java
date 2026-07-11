package com.project.foodsite.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.common.AdminUtil;
import com.project.foodsite.common.Paging;
import com.project.foodsite.dao.MemberDAO;
import com.project.foodsite.dao.ReportDAO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.dto.AdminMemberDTO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class AdminMemberContorller {
    
    private final HttpSession httpSession;
    private final AdminUtil adminUtil;
    private final MemberDAO memberDAO;
    private final ReportDAO reportDAO;

    // 회원 페이징 함수
    private void memberPaging(Model model, AdminMemberDTO admin){
        if(admin.getPage() <= 0){
            admin.setPage(1);
        }

        int totalcount = memberDAO.memberCount();

        Paging paging = new Paging(admin.getPage(), 5, totalcount);

        admin.setOffset(paging.getOffset());
        admin.setSize(paging.getSize());

        List<MemberVO> list = memberDAO.MemberSearch(admin);
        
        model.addAttribute("list", list);
        model.addAttribute("totalcount", totalcount );
        model.addAttribute("paging", paging);
        model.addAttribute("adminmember", admin);

    }

    // 회원 페이지 이동 함수
    @GetMapping("/admin/member")
    public String memberpage(AdminMemberDTO admin ,Model model){

        MemberVO user = (MemberVO)httpSession.getAttribute("user");
        
        model.addAttribute("profileuser",user);

        memberPaging(model, admin);

        adminUtil.setContentPage(model, "member");

        return "member/adminpage";
    }

    // 회원 상세 정보 조회
    @PostMapping("/admin/member/info")
    @ResponseBody
    public AdminMemberDTO memberDetail(AdminMemberDTO admin){     
        AdminMemberDTO member = memberDAO.memberDetail(admin.getMember_id());

        member.setReportList( reportDAO.adminReportList(admin.getMember_id()) );

        return member;

    }

    // 회원 정지 / 정지 해제
    @PostMapping("/admin/member/stop") 
    @ResponseBody
    public Map<String, Object> memberStop(int member_id){
        
        MemberVO user = memberDAO.getUserByMemberId(member_id);

        if(user.getStatus().equals("ACTIVE")){
            user.setStatus("SUSPEND");
        }else if(user.getStatus().equals("SUSPEND")){
            user.setStatus("ACTIVE");
        }

        int res = memberDAO.userUpdate(user);

        Map<String,Object> map = new HashMap<>();
        
        map.put("result", res);
        map.put("status",user.getStatus());
        map.put("nickname",user.getNickname());

        return map;

    } 

    // 회원 등급 변경(관리자 => 일반 회원/ 일반회원 => 관리자)
    @PostMapping("/admin/member/role")
    @ResponseBody
    public Map<String,Object> memberrole( MemberVO vo ){

        MemberVO user = memberDAO.getUserByMemberId(vo.getMember_id());

        MemberVO loginuser = (MemberVO)httpSession.getAttribute("user");
        
        Map<String,Object> map = new HashMap<>();
        
        if( loginuser.getMember_id() == user.getMember_id() ){

            map.put("msg","자기 자신의 권한은 설정 할수 없습니다.");

            return map;
        }

        if("ADMIN".equals(user.getRole())){

            user.setRole("USER");
            

        } else {

            user.setRole("ADMIN");

        }

        int res = memberDAO.userUpdate(user);
        

        map.put("result", res);
        map.put("role", user.getRole());
        
        return map;

    }
    

}
