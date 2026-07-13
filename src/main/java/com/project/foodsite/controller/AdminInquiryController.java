package com.project.foodsite.controller;

import java.text.SimpleDateFormat;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.project.foodsite.common.MailSendService;
import com.project.foodsite.common.Paging;
import com.project.foodsite.dao.ImgDAO;
import com.project.foodsite.dao.InquiryDAO;
import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.InquiryVO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class AdminInquiryController {

    private final InquiryDAO inquiryDao;
    private final MailSendService mailSendService;
    private final ImgDAO imgDao;

    // 관리자 문의 목록 조회
    @GetMapping("/admin/inquiry")
    public String adminInquiryList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "") String status,
            @RequestParam(defaultValue = "") String sort,
            @RequestParam(defaultValue = "") String type,
            HttpSession session,
            Model model
    ) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        // 관리자 계정이 아닌 경우 메인 페이지로 이동
        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/main_list.do";
        }

        if (page <= 0) {
            page = 1;
        }

        List<InquiryVO> allList = inquiryDao.adminInquiryList();

        if (!status.isBlank()) { 
            allList.removeIf(vo -> !status.equals(vo.getStatus()));
        }

        if (!type.isBlank()) { 
            allList.removeIf(vo -> !type.equals(vo.getType()));
        }

        // 선택한 정렬 기준에 따라 문의 목록 정렬
        if ("oldest".equals(sort)) {
            allList.sort((a, b) ->
                Long.compare(a.getInquiry_id(), b.getInquiry_id()));

        } else if ("title".equals(sort)) {

            allList.sort((a, b) ->
                a.getTitle().compareToIgnoreCase(b.getTitle()));

        } else {

            allList.sort((a, b) ->
                Long.compare(b.getInquiry_id(), a.getInquiry_id()));
        }

        int totalcount = allList.size();

        Paging paging = new Paging(page, 10, totalcount);

        int start = paging.getOffset();

        // 잘못된 페이지 요청 시 첫 페이지로 재설정
        if (start > totalcount) {
            page = 1;
            paging = new Paging(page, 10, totalcount);
            start = paging.getOffset();
        }

        int end = Math.min(start + paging.getSize(), totalcount);

        List<InquiryVO> list = allList.subList(start, end);

        model.addAttribute("list", list);
        model.addAttribute("paging", paging);
        model.addAttribute("totalcount", totalcount);
        model.addAttribute("page", page);

        model.addAttribute("status", status);
        model.addAttribute("sort", sort);    
        model.addAttribute("type", type);     

        model.addAttribute("profileuser", user);        
        model.addAttribute("menu", "inquiry");
        model.addAttribute("contentPage", "/WEB-INF/views/inquiry/adminInquiryList.jsp");

        return "member/adminpage";
    }

    // 관리자 문의 상세 조회
    @GetMapping("/inquiry/admin/detail")
    public String adminInquiryDetail(
            @RequestParam("inquiry_id") int inquiry_id,
            HttpSession session,
            Model model
    ) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/main_list.do";
        }

        // 문의 상세 정보 조회
        InquiryVO vo = inquiryDao.adminInquiryDetail(inquiry_id);

        // 해당 문의에 등록된 첨부 이미지 조회
        List<ImgVO> imgList = imgDao.img_select_inquiry(inquiry_id);

        model.addAttribute("vo", vo);

        model.addAttribute("imgList", imgList);

        return "inquiry/adminInquiryDetail";
    }

    // 관리자 문의 답변 등록
    @PostMapping("/inquiry/admin/answer")
    public String answerInquiry(
            InquiryVO vo,
            HttpSession session
    ) {

        MemberVO admin = (MemberVO) session.getAttribute("user");

        // 관리자 권한 확인
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            return "redirect:/main_list.do";
        }

        vo.setAdmin_id(admin.getMember_id());

        inquiryDao.answerInquiry(vo);

        // 답변 완료 후 이메일 발송을 위해 문의 정보 다시 조회
        InquiryVO inquiry = inquiryDao.adminInquiryDetail(vo.getInquiry_id());

        // 비회원 문의이고 이메일이 존재할 경우 답변 완료 메일 발송
        if (inquiry.getGuest_email() != null && !inquiry.getGuest_email().isEmpty()) {

            String createdDate = new SimpleDateFormat("yyyy-MM-dd")
                    .format(inquiry.getCreated_date());

            mailSendService.sendInquiryAnswerEmail(
                    inquiry.getGuest_email(),
                    inquiry.getInquiry_code(),
                    inquiry.getTitle(),
                    inquiry.getType(),
                    createdDate
            );
        }

        return "redirect:/inquiry/admin/detail?inquiry_id=" + vo.getInquiry_id();
    }
}