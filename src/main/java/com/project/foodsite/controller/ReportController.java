package com.project.foodsite.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.project.foodsite.common.Paging;
import com.project.foodsite.dao.ReportDAO;
import com.project.foodsite.vo.BoardVO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.ReportVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ReportController {

    private final ReportDAO reportDao;
    private final HttpSession session;

    @GetMapping("/report/form.do")
    public String reportForm(ReportVO vo, Model model) {

        if (vo.getBoard_id() != null) {
            BoardVO board = reportDao.selectBoardForReport(vo.getBoard_id());
            model.addAttribute("board", board);
        }

        if (vo.getRecipe_id() != null) {
            ReportVO recipe = reportDao.selectRecipeForReport(vo.getRecipe_id());
            model.addAttribute("recipe", recipe);
        }

        if (vo.getComment_id() != null) {
            ReportVO comment = reportDao.selectCommentForReport(vo.getComment_id());
            model.addAttribute("comment", comment);
        }

        if (vo.getReview_id() != null) {
            ReportVO review = reportDao.selectReviewForReport(vo.getReview_id());
            model.addAttribute("review", review);
        }

        setTargetType(vo);
        model.addAttribute("report", vo);

        return "report/report_form";
    }

    @PostMapping("/report/insert.do")
    public String reportInsert(
            ReportVO vo,
            RedirectAttributes redirectAttributes) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null) {
            redirectAttributes.addFlashAttribute(
                    "reportMessage",
                    "로그인 후 이용해주세요."
            );

            return "redirect:/login.do";
        }

        vo.setMember_id(user.getMember_id());

        boolean noTarget =
                vo.getBoard_id() == null &&
                vo.getComment_id() == null &&
                vo.getRecipe_id() == null &&
                vo.getReview_id() == null;

        if (noTarget) {
            redirectAttributes.addFlashAttribute(
                    "reportMessage",
                    "신고 대상이 없습니다."
            );

            return "redirect:/main_list.do";
        }

        setTargetType(vo);

        int result = reportDao.reportInsert(vo);

        if (result > 0) {

            int count =
                    reportDao.sameMemberSameTargetPendingReportCount(vo);

            if (count >= 3) {
                reportDao.updateMemberReportCount(vo.getMember_id());
                reportDao.updateSameMemberSameTargetReportStatusWarning(vo);
            }

            redirectAttributes.addFlashAttribute(
                    "reportMessage",
                    "신고되었습니다."
            );

        } else {
            redirectAttributes.addFlashAttribute(
                    "reportMessage",
                    "신고 처리에 실패했습니다."
            );
        }

        return "redirect:/main_list.do";
    }

    @GetMapping("/report/admin/list.do")
    public String reportAdminList(
            Model model,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "member_id", defaultValue = "0") int member_id) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/main_list.do";
        }

        model.addAttribute("profileuser", user);

        int totalcount = reportDao.reportCount( member_id );

        Paging paging = new Paging(page, 10, totalcount);

        Map<String, Object> map = new HashMap<>();
        map.put("offset", paging.getOffset());
        map.put("size", paging.getSize());
        map.put("member_id", member_id);

        List<Map<String, Object>> list =
                reportDao.reportListPage(map);

        model.addAttribute("list", list);
        model.addAttribute("paging", paging);

        model.addAttribute("menu", "report");
        model.addAttribute(
                "contentPage",
                "/WEB-INF/views/report/report_adminList.jsp"
        );

        return "member/adminpage";
    }
    @PostMapping("/report/admin/warning.do")
    public String reportWarning(ReportVO vo) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/main_list.do";
        }

        ReportVO report = reportDao.selectReportOne(vo.getReport_id());

        if (report == null) {
            return "redirect:/report/admin/list.do";
        }

        Integer reportedMemberId = reportDao.selectReportedMemberId(report);

        if (reportedMemberId != null) {
            reportDao.updateMemberReportCount(reportedMemberId);
            reportDao.updateReportStatusWarning(vo.getReport_id());
        }

        return "redirect:/report/admin/list.do";
    }

    @PostMapping("/report/admin/delete.do")
    public String reportDelete(ReportVO vo) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/main_list.do";
        }

        reportDao.reportDelete(vo.getReport_id());

        return "redirect:/report/admin/list.do";
    }

    private void setTargetType(ReportVO vo) {

        if (vo.getReview_id() != null) {
            vo.setTarget_type("리뷰");
        } else if (vo.getRecipe_id() != null && vo.getComment_id() != null) {
            vo.setTarget_type("레시피 댓글");
        } else if (vo.getRecipe_id() != null) {
            vo.setTarget_type("레시피");
        } else if (vo.getBoard_id() != null && vo.getComment_id() != null) {
            vo.setTarget_type("커뮤니티 댓글");
        } else if (vo.getBoard_id() != null) {
            vo.setTarget_type("커뮤니티");
        }
    }
}