package com.project.foodsite.controller;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.common.ViewCount; 
import com.project.foodsite.dao.NoticeDAO;
import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.NoticeVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class NoticeController {
    // application.properties에 설정한 파일 업로드 경로
    @Value("${file.upload.path}")
    private String savePath;
    
    private final NoticeDAO noticeDao;
    private final HttpSession session;
    private final ViewCount viewCount; 

    // 공지사항 목록 조회, 제목 검색 및 페이징 처리
    @GetMapping("/notice.do")
    public String getArticleList(
            Model model,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "search_text", defaultValue = "") String search_text) {

        int pageSize = 8;
        int pageBlock = 5;
        int start = (page - 1) * pageSize;

        // 검색어와 페이지 범위에 해당하는 공지사항 목록 조회
        List<NoticeVO> notice = noticeDao.selectList(start, pageSize, search_text);
        int totalCount = noticeDao.notice_count(search_text);

        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        int startPage = ((page - 1) / pageBlock) * pageBlock + 1;
        int endPage = startPage + pageBlock - 1;

        if (endPage > totalPage) {
            endPage = totalPage;
        }

        String pageMenu = "";

        if (startPage > 1) {
            pageMenu += "<a href='notice.do?page=" + (startPage - 1)
                    + "&search_text=" + search_text + "'>◀</a> ";
        }

        for (int i = startPage; i <= endPage; i++) {
            if (i == page) {
                pageMenu += "<b>" + i + "</b> ";
            } else {
                pageMenu += "<a href='notice.do?page=" + i
                        + "&search_text=" + search_text + "'>" + i + "</a> ";
            }
        }

        if (endPage < totalPage) {
            pageMenu += "<a href='notice.do?page=" + (endPage + 1)
                    + "&search_text=" + search_text + "'>▶</a>";
        }

        model.addAttribute("notice", notice);
        model.addAttribute("page", page);
        model.addAttribute("pageMenu", pageMenu);
        model.addAttribute("search_text", search_text);
        model.addAttribute("totalCount", totalCount);

        return "notice/notice_list";
    }

    // 공지사항 상세 조회
    @GetMapping("/notice_detail.do")
    public String viewNotice(Model model, int notice_id) {

        // 중복 조회 방지 기능을 적용하여 조회수 증가
        viewCount.increaseNotice(notice_id); 

        // 공지사항 상세 정보 조회
        NoticeVO vo = noticeDao.noticeView(notice_id);

        ImgVO img = noticeDao.notice_img_select(notice_id);

        model.addAttribute("notice", vo);
        model.addAttribute("img", img);

        return "notice/detail_view";
    }

    // 공지사항 등록 페이지 이동
    @GetMapping("/notice_add.do")
    public String noticeAdd_form() {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:notice.do";
        }

        return "notice/add_form";
    }

    // 공지사항 및 다중 이미지 등록
    @PostMapping("/notice_add.do")
    public String noticeAdd_fin(
            NoticeVO vo,

            @RequestParam(value = "images", required = false) List<MultipartFile> images
    ) throws Exception {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:notice.do";
        }

        // 로그인한 관리자를 공지사항 작성자로 설정
        vo.setMember_id(user.getMember_id());

        noticeDao.notice_insert(vo);

        File dir = new File(savePath);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        List<String> fileNames = new ArrayList<>();
        
        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {

                if (image == null || image.isEmpty()) {
                    continue;
                }

                String filename = System.currentTimeMillis() + "_" + image.getOriginalFilename();
                File saveFile = new File(savePath, filename);

                if (saveFile.exists()) {
                    filename = System.currentTimeMillis() + "_" + filename;
                    saveFile = new File(savePath, filename);
                }

                image.transferTo(saveFile);
                fileNames.add(filename);
            }
        }

        if (!fileNames.isEmpty()) {
            ImgVO img = new ImgVO();
            img.setNotice_id(vo.getNotice_id());

            img.setImage_list(String.join(",", fileNames));

            noticeDao.notice_img_insert(img);
        }

        return "redirect:notice.do";
    }

    // 공지사항 수정 페이지 이동
    @GetMapping("/notice_update.do")
    public String noticeUpdate_form(int notice_id, Model model) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/notice.do";
        }

        NoticeVO vo = noticeDao.noticeView(notice_id);
        ImgVO img = noticeDao.notice_img_select(notice_id);

        model.addAttribute("notice", vo);
        model.addAttribute("img", img);

        return "notice/update_form";
    }

    // 공지사항 및 이미지 수정
    @PostMapping("/notice_update.do")
    public String noticeUpdate_fin(
            NoticeVO vo,

            @RequestParam(value = "images", required = false) List<MultipartFile> images,

            @RequestParam(value = "delete_image", required = false) List<String> delete_image
    ) throws Exception {

        MemberVO user = (MemberVO) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:/notice.do";
        }

        noticeDao.notice_update(vo);

        File dir = new File(savePath);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        ImgVO oldImg = noticeDao.notice_img_select(vo.getNotice_id());

        List<String> fileNames = new ArrayList<>();

        if (oldImg != null
                && oldImg.getImage_list() != null
                && !oldImg.getImage_list().trim().isEmpty()) {

            // 콤마 기준으로 분리
            fileNames.addAll(Arrays.asList(oldImg.getImage_list().split(",")));
        }

        // X 누른 기존 이미지 제거
        if (delete_image != null && !delete_image.isEmpty()) {
            fileNames.removeAll(delete_image);
        }

        // 새로 선택한 이미지 저장
        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {

                if (image == null || image.isEmpty()) {
                    continue;
                }

                String filename = System.currentTimeMillis() + "_" + image.getOriginalFilename();
                File saveFile = new File(savePath, filename);

                if (saveFile.exists()) {
                    filename = System.currentTimeMillis() + "_" + filename;
                    saveFile = new File(savePath, filename);
                }

                image.transferTo(saveFile);
                fileNames.add(filename);
            }
        }

        if (fileNames.isEmpty()) {
            noticeDao.notice_img_delete(vo.getNotice_id());

        } else {
            ImgVO img = new ImgVO();
            img.setNotice_id(vo.getNotice_id());

            // 기존에 남은 이미지와 새 이미지를 다시 쉼표로 연결
            img.setImage_list(String.join(",", fileNames));

            if (oldImg == null) {
                // 기존 이미지가 없었다면 새로 등록
                noticeDao.notice_img_insert(img);
            } else {
                // 기존 이미지가 있었다면 이미지 목록 수정
                noticeDao.notice_img_update(img);
            }
        }

        return "redirect:/notice_detail.do?notice_id=" + vo.getNotice_id();
    }

    // 공지사항 삭제
    @GetMapping("/notice_delete.do")
    public String noticeDelete(int notice_id) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        // 관리자만 공지사항 삭제 가능
        if (user == null || !"ADMIN".equals(user.getRole())) {
            return "redirect:notice.do";
        }

        // 외래키 오류 방지를 위해 이미지 정보를 먼저 삭제
        noticeDao.notice_img_delete(notice_id);
        // 공지사항 삭제
        noticeDao.notice_delete(notice_id);

        return "redirect:notice.do";
    }
}