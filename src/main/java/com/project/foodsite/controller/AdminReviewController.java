package com.project.foodsite.controller;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.common.AdminUtil;
import com.project.foodsite.common.Paging;
import com.project.foodsite.dao.ReviewDAO;
import com.project.foodsite.dto.AdminReviewDTO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class AdminReviewController {
    private final HttpSession httpSession;
    private final ReviewDAO reviewDAO;
    private final AdminUtil adminUtil;

    // 후기 페이징 함수
    private void ReviewPaging(Model model,AdminReviewDTO Review){

        if(Review.getPage() <= 0){
            Review.setPage(1);
        }

        int totalcount = reviewDAO.ReviewCount(Review);

        Paging paging = new Paging(Review.getPage(), 5 , totalcount);

        Review.setSize(paging.getSize());
        Review.setOffset(paging.getOffset());

        List<AdminReviewDTO> list = reviewDAO.ReviewSearch(Review);
        
        model.addAttribute("list",list);
        model.addAttribute("paging",paging);
        model.addAttribute("totalcount",totalcount);
        model.addAttribute("adminreview",Review);

    }

    // 관리자 후기 관리 페이지
    @GetMapping("/admin/review")
    public String recipecommentpage(Model model, AdminReviewDTO Review){

        MemberVO user = (MemberVO)httpSession.getAttribute("user");

        model.addAttribute("profileuser", user);   

        adminUtil.setContentPage(model, "review");

        ReviewPaging(model, Review);

        return "member/adminpage";
    }

    // 후기 상세정보 조회
    @PostMapping("/admin/review/view")
    @ResponseBody
    public AdminReviewDTO reviewDetail(int review_id){

        return reviewDAO.adminReviewDetail(review_id);

    }

    // 후기 공개/비공개 처리
    @PostMapping("/admin/review/hidden")
    @ResponseBody
    public Map<String,Object> reviewHidden(int review_id){

        AdminReviewDTO Review = reviewDAO.adminReviewDetail(review_id);

        if (Review.getStatus().equals("ACTIVE") ){
            Review.setStatus("HIDDEN");
        } else if ( Review.getStatus().equals("HIDDEN")  ){
            Review.setStatus("ACTIVE");
        }

        int res = reviewDAO.reviewStatus(Review);

        Map<String,Object> map = new HashMap<>();

        map.put("result", res);
        map.put("status", Review.getStatus());

        return map;

    }

    // 후기 삭제/복원
    @PostMapping("/admin/review/delete")
    @ResponseBody
    public Map<String,Object> boardDelete(int review_id){

        AdminReviewDTO Review = reviewDAO.adminReviewDetail(review_id);

        if (Review.getStatus().equals("DELETE") ){
            Review.setStatus("ACTIVE");
        } else if ( Review.getStatus().equals("ACTIVE") || Review.getStatus().equals("HIDDEN") ){
            Review.setStatus("DELETE");
        }

        int res = reviewDAO.reviewStatus(Review);

        Map<String,Object> map = new HashMap<>();

        map.put("result", res);
        map.put("status", Review.getStatus());

        return map;

    }

}
