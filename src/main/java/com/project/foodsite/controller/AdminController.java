package com.project.foodsite.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.common.AdminUtil;
import com.project.foodsite.common.Fileupload;
import com.project.foodsite.dao.MemberDAO;
import com.project.foodsite.dao.RecipeDAO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.RecipeVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;




@Controller
@RequiredArgsConstructor
public class AdminController {

    @Value("${file.upload.path}")
    private String uploadPath;

    private final HttpSession httpSession;
    private final RecipeDAO recipeDAO;
    private final AdminUtil adminUtil;
    private final Fileupload fileupload;
    private final MemberDAO memberDAO;
    
    // 관리자 페이지 이동 함수
    @GetMapping("/admin")
    public String adminpage(Model model) {

        MemberVO user = (MemberVO) httpSession.getAttribute("user");

        List<RecipeVO> recentlyRecipe = recipeDAO.recentlyrecipe();

        adminUtil.getTotalCount(model);

        model.addAttribute("profileuser", user);
        model.addAttribute("list",recentlyRecipe);
        model.addAttribute("contentPage", "/WEB-INF/views/member/admin/admin_home.jsp");

        return "member/adminpage";

    }

    @GetMapping("/admin/mypage")
    public String adminmypage(Model model){

        MemberVO user = (MemberVO) httpSession.getAttribute("user");

        model.addAttribute("profileuser",user);
        
        adminUtil.setContentPage(model, "mypage");

        return "member/adminpage";

    } 

    @GetMapping("/admin/update")
    public String getMethodName(Model model) {
        MemberVO user = (MemberVO) httpSession.getAttribute("user");

        model.addAttribute("profileuser", user);
        model.addAttribute("contentPage", "/WEB-INF/views/member/admin/admin_update.jsp");

        return "member/adminpage";
    }
    

    @PostMapping("/admin/updatefin")
    public String getMethodName(MemberVO vo, String filechange) throws Exception {
        MemberVO user = (MemberVO)httpSession.getAttribute("user");
        String savePath = "profile";
        String filename = user.getProfile_img();

        MultipartFile photo = vo.getPhoto();

        if(filechange.equals("yes")){

            fileupload.deleteFile(filename, savePath);

            filename = "no_file.png";

        }else if(photo != null && !photo.isEmpty()){

            fileupload.deleteFile(filename,savePath);
            filename = fileupload.saveFile(photo, savePath);

        }else{
            filename = user.getProfile_img();
        }

        vo.setMember_id(user.getMember_id());
        vo.setFilename(filename);

        int res = memberDAO.userUpdate(vo);

        if(res > 0){
            MemberVO updateduser = memberDAO.getUserByMemberId(vo.getMember_id());
            httpSession.setAttribute("user", updateduser);

            return "redirect:/admin/mypage";
        }else{
            return "redirect:/admin/update";
        }
    }
    
    

    

}
