package com.project.foodsite.controller;

import java.io.File;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.common.pwdSecurity;
import com.project.foodsite.dao.ImgDAO;
import com.project.foodsite.dao.InquiryDAO;
import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.InquiryVO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class InquiryController {

    // application.properties에 설정한 파일 업로드 경로
    @Value("${file.upload.path}")
    private String uploadPath;

    private final InquiryDAO inquiryDao;
    private final ImgDAO imgDao;
    private final pwdSecurity pwdSecurity;

    // 문의 작성 페이지 이동
    @GetMapping("/inquiry")
    public String inquiryform(HttpServletRequest request, HttpSession session) {

        String referer = request.getHeader("Referer");

        if (referer != null && !referer.contains("/inquiry")) {
            session.setAttribute("prevPage", referer);
        }

        return "inquiry/inquiryForm";
    }

    // 문의 등록
    @PostMapping("/inquiry")
    public String insertInquiry(
            InquiryVO vo,
            @RequestParam(value = "image", required = false) MultipartFile[] images,
            HttpSession session
    ) throws Exception {

        MemberVO user = (MemberVO) session.getAttribute("user");

        // 문의 등록 시 기본 처리 상태를 미답변 상태로 설정
        vo.setStatus("n");

        if (user != null) {
            // 회원 문의는 로그인한 회원 번호 저장
            vo.setMember_id(user.getMember_id());

            // 회원 문의이므로 비회원 정보는 저장하지 않음
            vo.setGuest_name(null);
            vo.setGuest_email(null);
            vo.setGuest_password(null);
        } else {

            // 비회원 문의 비밀번호는 암호화 후 저장
            String encPwd = pwdSecurity.pwdEncoding(vo.getGuest_password());
            vo.setGuest_password(encPwd);
        }

        inquiryDao.insertInquiry(vo);

        // 문의 ID를 이용해 비회원 확인용 고유 코드 생성
        String inquiryCode = createInquiryCode(vo.getInquiry_id());

        vo.setInquiry_code(inquiryCode);

        inquiryDao.updateInquiryCode(vo);

        if (images != null && images.length > 0) {

            // String savePath = "/Users/shinyeyoung/upload/";

            File dir = new File(uploadPath);

            // 업로드 폴더가 없으면 자동 생성
            if (!dir.exists()) {
                dir.mkdirs();
            }

            for (MultipartFile image : images) {

                if (image == null || image.isEmpty()) {
                    continue;
                }

                String filename = image.getOriginalFilename();

                //파일 중복 방지
                long time = System.currentTimeMillis();
                filename = time + "_" + filename;

                File saveFile = new File(uploadPath, filename);

                image.transferTo(saveFile);

                ImgVO img = new ImgVO();
                img.setImage_list(filename);
                img.setInquiry_id(vo.getInquiry_id());

                imgDao.img_insert(img);
            }
        }

        String prevPage = (String) session.getAttribute("prevPage");

        if (prevPage != null && !prevPage.isBlank()) {
            session.removeAttribute("prevPage");
            return "redirect:" + prevPage;
        }

        return "redirect:/main_list.do";
    }

    // 비회원 문의 비밀번호 확인 페이지
    @GetMapping("/guest/inquiry/check")
    public String guestInquiryPasswordForm(
            @RequestParam("code") String inquiry_code,
            Model model
    ) {

        // 문의 확인 코드로 문의 조회
        InquiryVO vo = inquiryDao.guestInquiryCode(inquiry_code); 

        // 문의 코드와 일치하는 문의가 없는 경우
        if (vo == null) { 
            model.addAttribute("msg", "존재하지 않는 문의입니다."); 
            return "inquiry/guestInquiryPasswordForm"; 
        }

        LocalDateTime createdDate = vo.getCreated_date() 
                .toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();
        // 테스트용 70초
        LocalDateTime expireDate = createdDate.plusSeconds(70); 
        // 비회원 문의 확인 기간 7일
        //LocalDateTime expireDate = createdDate.plusDays(7); 


        // 문의 확인 기간이 지난 경우 만료 처리
        if (LocalDateTime.now().isAfter(expireDate)) { 
            model.addAttribute("expired", "yes"); 
            return "inquiry/guestInquiryPasswordForm"; 
        }

        model.addAttribute("inquiry_code", inquiry_code);
        return "inquiry/guestInquiryPasswordForm";
    }

    // 비회원 문의 비밀번호 검증
    @PostMapping("/guest/inquiry/check")
    public String guestInquiryCheck(
            @RequestParam("inquiry_code") String inquiry_code,
            @RequestParam("guest_password") String guest_password,
            Model model
    ) {

        InquiryVO vo = inquiryDao.guestInquiryCode(inquiry_code);

        // 존재하지 않는 문의 코드인 경우
        if (vo == null) {

            model.addAttribute("msg", "존재하지 않는 문의입니다.");
            model.addAttribute("inquiry_code", inquiry_code);
            return "inquiry/guestInquiryPasswordForm";
        }


        boolean pwdCheck = pwdSecurity.pwdDecoding(guest_password, vo.getGuest_password());

        if (!pwdCheck) {
            model.addAttribute("msg", "비밀번호가 일치하지 않습니다.");
            model.addAttribute("inquiry_code", inquiry_code);
            return "inquiry/guestInquiryPasswordForm";
        }

        List<ImgVO> imgList = imgDao.img_select_inquiry(vo.getInquiry_id());

        model.addAttribute("vo", vo);
        model.addAttribute("imgList", imgList);

        return "inquiry/guestInquiryDetail";
    }

    // 랜덤 문자열 생성
    private String createToken() {
        SecureRandom secureRandom = new SecureRandom();

        byte[] bytes = new byte[16];
        secureRandom.nextBytes(bytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes);
    }

    // 비회원 문의 확인용 고유 코드 생성
    private String createInquiryCode(Integer inquiryId) {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String token = createToken();

        // 날짜, 문의 번호, 랜덤 토큰을 조합
        return "INQ-" + date + "-" + inquiryId + "-" + token;
    }
}