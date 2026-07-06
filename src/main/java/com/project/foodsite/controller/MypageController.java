package com.project.foodsite.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam; // 추가
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.common.Fileupload;
import com.project.foodsite.common.Paging;
import com.project.foodsite.common.pwdSecurity;
import com.project.foodsite.dao.ActivityDAO;
import com.project.foodsite.dao.BookmarkDAO;
import com.project.foodsite.dao.CommentDAO;
import com.project.foodsite.dao.ImgDAO;
import com.project.foodsite.dao.InquiryDAO;
import com.project.foodsite.dao.MemberDAO;
import com.project.foodsite.dao.RecipeDAO;
import com.project.foodsite.dto.MypageDTO;
import com.project.foodsite.vo.BookmarkVO;
import com.project.foodsite.vo.CommentVO;
import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.InquiryVO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.RecipeVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class MypageController {

    @Value("${file.upload.path}")
    private String uploadPath;

    private final HttpSession httpSession;    

    private final MemberDAO memberDAO;
    private final pwdSecurity pwdSecurity; 
    private final Fileupload fileupload;
    private final RecipeDAO recipeDAO;
    private final ActivityDAO activityDAO;
    private final CommentDAO commentDAO;
    private final BookmarkDAO bookmarkDAO;
    private final InquiryDAO inquiryDAO; 
    private final ImgDAO imgDAO;
    

    private Paging applyPaging(MypageDTO mypageDTO, int totalcount, Model model){
        if(mypageDTO.getPage() == 0){
            mypageDTO.setPage(1);
        }

        if(mypageDTO.getSize() == 0){
            mypageDTO.setSize(5);
        }

        if(mypageDTO.getSort() == null || mypageDTO.getSort().isBlank()){
            mypageDTO.setSort("recently");
        }

        Paging paging = new Paging(mypageDTO.getPage(), mypageDTO.getSize(), totalcount);
        mypageDTO.setOffset(paging.getOffset());

        model.addAttribute("paging", paging);
        model.addAttribute("sort", mypageDTO.getSort());

        return paging;
    }

    private void userRecipePaging( MypageDTO mypageDTO , Model model){
        
        int totalcount = recipeDAO.countUserRecipe( mypageDTO );
        applyPaging(mypageDTO, totalcount, model);

        List<RecipeVO> list = recipeDAO.getUserRecipeList(mypageDTO);

        model.addAttribute("list", list);
    }

    private void userCommentPaging( MypageDTO mypageDTO, Model model){
        
        int totalcount = commentDAO.countUserComment(mypageDTO);
        applyPaging(mypageDTO, totalcount, model);

        List<CommentVO> list = commentDAO.getUserCommentList(mypageDTO);

        model.addAttribute("list", list);
    }

    private void userBookmarkPaging(MypageDTO mypageDTO, Model model){
        
        int totalcount = bookmarkDAO.countUserBookmark(mypageDTO);
        applyPaging(mypageDTO, totalcount, model);

        List<BookmarkVO> list = bookmarkDAO.getUserBookmarkList(mypageDTO);

        model.addAttribute("list", list);
    }

    public void userHomePage(Model model, int member_id){
        model.addAttribute("activity", activityDAO.userActivity(member_id));
        model.addAttribute("recentlyRecipeList", recipeDAO.recentlyUserRecipe(member_id));
        model.addAttribute("commentList", commentDAO.userComment(member_id));
        model.addAttribute("bookmarkList", bookmarkDAO.userBookmark(member_id));
    }

    private void userInquiry(int page, Model model, MemberVO user, String status){

        List<InquiryVO> allList = inquiryDAO.myInquiryList(user.getMember_id());

        if (status != null && !status.isBlank()) {
            allList.removeIf(vo -> !status.equals(vo.getStatus()));
        }

        int totalcount = allList.size();

        Paging paging = new Paging(page, 10, totalcount);

        int start = paging.getOffset();

        if (start >= totalcount && totalcount > 0) {
            page = 1;
            paging = new Paging(page, 10, totalcount);
            start = paging.getOffset();
        }

        int end = Math.min(start + paging.getSize(), totalcount);

        List<InquiryVO> inquiryList = allList.subList(start, end);

        Map<Integer, List<ImgVO>> inquiryImgMap = new HashMap<>();

        for (InquiryVO inquiry : inquiryList) {
            List<ImgVO> imgList = imgDAO.img_select_inquiry(inquiry.getInquiry_id());
            inquiryImgMap.put(inquiry.getInquiry_id(), imgList);
        }      

        model.addAttribute("inquiryList", inquiryList);
        model.addAttribute("inquiryImgMap", inquiryImgMap);
        
        model.addAttribute("paging", paging);
        model.addAttribute("page", page);
        model.addAttribute("totalcount", totalcount);
        model.addAttribute("startPage", paging.getStartpage());
        model.addAttribute("endPage", paging.getEndpage());
        model.addAttribute("totalPage", paging.getTotalpage());
        model.addAttribute("prev", paging.isPrev());
        model.addAttribute("next", paging.isNext());

        model.addAttribute("status", status);
    }

    private void setContentPage(Model model, String menu){

        boolean mainshow = false;

        String contentPage = "/WEB-INF/views/member/mypage/mypage_home.jsp";
        
        if (menu.equals("inquiry")) {
            mainshow = true;
            contentPage = "/WEB-INF/views/member/mypage/mypageinquiry.jsp";
        } else if (menu.equals("update")) {
            contentPage = "/WEB-INF/views/member/mypage/mypage_modify.jsp";  
            mainshow = true;          
        } else if (menu.equals("pwd")) {
            contentPage = "/WEB-INF/views/member/mypage/mypage_pwd.jsp";    
            mainshow = true;       
        } else if (menu.equals("del")) {
            contentPage = "/WEB-INF/views/member/mypage/mypage_del.jsp";            
            mainshow = true;          
        } else if (menu.equals("account" )){
            contentPage = "/WEB-INF/views/member/mypage/mypage_info.jsp";                       
        } else if (menu.equals("recipe")){
            contentPage = "/WEB-INF/views/member/mypage/mypage_myrecipe.jsp";                         
        } else if (menu.equals("comment")){
            contentPage = "/WEB-INF/views/member/mypage/mypage_mycomment.jsp";                          
        } else if (menu.equals("bookmark")){
            contentPage = "/WEB-INF/views/member/mypage/mypage_bookmark.jsp";                        
        } 
        
        model.addAttribute("contentPage", contentPage);
        model.addAttribute("mainshow", mainshow);
    }

    private void setTotalCount(int member_id, Model model){
        MypageDTO mypageDTO = new MypageDTO();
        mypageDTO.setMember_id(member_id);

        model.addAttribute("recipeCount", recipeDAO.countUserRecipe(mypageDTO));
        model.addAttribute("commentCount", commentDAO.countUserComment(mypageDTO));
        model.addAttribute("bookmarkCount", bookmarkDAO.countUserBookmark(mypageDTO));
    }
    
    @GetMapping("/user/{member_id}")
    public String viewUser(@PathVariable int member_id, Model model, MypageDTO mypageDTO ){

        MemberVO profileUser = memberDAO.getUserByMemberId(member_id);

        if(mypageDTO.getPage() == 0){
            mypageDTO.setPage(1) ;
        }
        
        if(mypageDTO.getMenu() == null){
            mypageDTO.setMenu("home");
        }
        
        if(profileUser == null){
            model.addAttribute("notfound", true);
            model.addAttribute("contentPage", "/WEB-INF/views/member/mypage/mypage_profile_notfound.jsp");
            return "member/mypage/mypage_profile";
        }                      
        
        model.addAttribute("profileUser", profileUser);
        model.addAttribute("member_id", member_id);
        model.addAttribute("menu", mypageDTO.getMenu()); 
        mypageDTO.setMember_id(member_id);
        
        String contentPage = "/WEB-INF/views/member/mypage/mypage_profile_home.jsp";
        userHomePage(model, member_id);
        
        if (mypageDTO.getMenu().equals("recipe")){
            userRecipePaging(mypageDTO, model);
            contentPage = "/WEB-INF/views/member/mypage/mypage_profile_recipe.jsp";
        } else if(mypageDTO.getMenu().equals("comment")){
            userCommentPaging(mypageDTO, model);
            contentPage = "/WEB-INF/views/member/mypage/mypage_profile_comment.jsp";
        } 

        setTotalCount(member_id, model);
        
        model.addAttribute("contentPage", contentPage);

        return "member/mypage/mypage_profile";
    }   

    @GetMapping("/mypage.do")
    public String gomypage(
            Model model,
            MypageDTO mypageDTO,
            @RequestParam(required = false) String status 
    ) {        

        if(mypageDTO.getPage() == 0){
            mypageDTO.setPage(1);
        }

        if(mypageDTO.getMenu() == null){
            mypageDTO.setMenu("home");
        }
        
        MemberVO user = (MemberVO) httpSession.getAttribute("user");

        if(user == null){
            setContentPage(model, mypageDTO.getMenu());
            return "member/mypage";
        }
        
        mypageDTO.setMember_id(user.getMember_id());
        model.addAttribute("profileuser", user);
        model.addAttribute("menu", mypageDTO.getMenu());
        
        if(mypageDTO.getMenu().equals("home")){
            userHomePage(model, user.getMember_id());
        } else if(mypageDTO.getMenu().equals("recipe")){
            userRecipePaging(mypageDTO, model);
        } else if(mypageDTO.getMenu().equals("comment")){
            userCommentPaging(mypageDTO, model);
        } else if(mypageDTO.getMenu().equals("bookmark")){
            userBookmarkPaging(mypageDTO, model);
        } else if(mypageDTO.getMenu().equals("inquiry")){
            userInquiry(mypageDTO.getPage(), model, user, status);
        }

        setTotalCount(user.getMember_id(), model);

        setContentPage(model, mypageDTO.getMenu());
        
        return "member/mypage";
    }
   
    @PostMapping("/mypage_update.do")
    public String update(MemberVO vo, String filechange) throws Exception{

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

            return "redirect:/mypage.do?menu=account";
        }else{
            return "redirect:/mypage.do?menu=update";
        }
    }

    @PostMapping("/userpwdcheck.do")
    @ResponseBody
    public String userpwdcheck(String currpwd){

        MemberVO user = (MemberVO)httpSession.getAttribute("user");
             
        if(pwdSecurity.pwdDecoding(currpwd, user.getPassword())){
            return "ok";
        }

        return "no";
    }

    @PostMapping("/resetpwdpage.do")
    @ResponseBody
    public String userrestpassword(String password){

        String enc_pwd = pwdSecurity.pwdEncoding(password);

        MemberVO user = (MemberVO)httpSession.getAttribute("user");

        MemberVO vo = new MemberVO();
        
        vo.setMember_id(user.getMember_id());
        vo.setPassword(enc_pwd);
        
        int res = memberDAO.userPwdUpdate(vo);
        
        if(res > 0){
            return "success";
        } else{
            return "fail";
        }
    }

    @PostMapping("/secessionUser.do")
    @ResponseBody
    public String secessionuser(MemberVO vo){

        String savePath = uploadPath + "/profile";

        fileupload.deleteFile(savePath, vo.getProfile_img());

        vo.setStatus("WITHDRAW");
        vo.setLogin_id(null);
        vo.setPassword(null);
        vo.setNickname("탈퇴회원_" + vo.getMember_id());
        vo.setEmail("withdraw_" + vo.getMember_id() + "@delete.com");
        vo.setProvider(null);
        vo.setProvider_id(null);
        vo.setMember_intro(null);
        vo.setName("탈퇴");
        vo.setProfile_img("no_file.png");
        
        int res = memberDAO.secessionUser(vo);

        if(res > 0){
            httpSession.removeAttribute("user");
            return "yes";
        }else{
            return "no";
        }        
    }
    @GetMapping("/terms.do")
    public String terms() {
        return "etc/terms";
    }

    @GetMapping("/privacy.do")
    public String privacy() {
        return "etc/privacy";
    }

}
