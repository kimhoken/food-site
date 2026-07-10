package com.project.foodsite.controller;

import com.project.foodsite.common.ViewCount;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.dao.ReviewDAO;
import com.project.foodsite.dto.ReviewDetailDTO;
import com.project.foodsite.vo.ImgVO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.RecipeVO;
import com.project.foodsite.vo.ReviewVO;

import jakarta.servlet.http.HttpSession;

import com.project.foodsite.common.Fileupload;
import com.project.foodsite.dao.ImgDAO;
import com.project.foodsite.dao.RecipeDAO;


import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ReviewController {

    private final ViewCount viewCount;    
    private final HttpSession httpSession;
    
    private final ReviewDAO reviewDao;
    private final RecipeDAO recipeDao;
    private final Fileupload fileupload;
    private final ImgDAO imgDAO;
   
    // 레시피 등록 폼으로 연결
    @GetMapping("/review/insert")
    public String review_insert_page( Model model ,int recipe_id ){

        RecipeVO recipe = recipeDao.selectOne(recipe_id);

        model.addAttribute("recipe", recipe);

        return "review/review_insert";
    }

    //레시피 등록 함수
    @PostMapping("/review/insert")
    @ResponseBody
    public Map<String, Object> reviewinsert(ReviewVO review){

        MemberVO user = (MemberVO)httpSession.getAttribute("user");

        review.setMember_id(user.getMember_id());
        
        List<MultipartFile> files = review.getPhoto();

        Map<String, Object> map = new HashMap<>();

        if (files != null && !files.isEmpty()){
            try {
                String filenames = fileupload.saveFiles(files, "review");                

                int res = reviewDao.reviewInsert(review);

                if(res == 0){
                    map.put("result", "fail");
                    return  map;
                }
                
                int review_id = review.getReview_id();

                if(filenames != null && !filenames.isEmpty()){

                    ImgVO img = new ImgVO();
    
                    img.setImage_list(filenames);
                    img.setReview_id(review_id);
    
                    imgDAO.img_insert_review(img);
                }

                map.put("result", "success");

                return map;


            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
                map.put("result","error");
                return map;
            }
            
        } else {
            map.put("result","error");
            return map;
        }
    }

    // 후기 불려오기 
    @PostMapping("/review/detail")
    @ResponseBody
    public ReviewDetailDTO reviewdetail(int review_id){

        MemberVO user = (MemberVO)httpSession.getAttribute("user");

        viewCount.increaseReview(review_id);

        ReviewDetailDTO review = reviewDao.selectreview(review_id);

        if(review.getImage_list() != null && !review.getImage_list().isBlank()){
            
            review.setImgList(Arrays.asList(review.getImage_list().split(",")));
            review.setThumbnail(review.getImage_list().split(",")[0]);
        }

        if(user == null){
            review.setOwner(false);
        }else{
            review.setOwner(review.getMember_id() == user.getMember_id());
        }        

        return review;
    }

    //레시피 삭제 
    @PostMapping("/review/delete")
    @ResponseBody
    public Map<String, Object> reviewDelete( int review_id ) {
        
        Map<String, Object> map = new HashMap<>();

        ReviewDetailDTO review = reviewdetail(review_id);

        if (review.getImage_list() != null && review.getImage_list().isBlank()){
            fileupload.deleteFiles(review.getImage_list(), "review");
        }

        imgDAO.img_delete(review.getReview_id());

        map.put("title", review.getTitle());

        int res = reviewDao.deletereview(review_id);

        map.put("result", res);

        return map;


    }

    //레시피 수정 페이지
    @GetMapping("/review/modify")
    public String reviewmodify( Model model, int review_id ){

        ReviewDetailDTO review = reviewDao.selectreview(review_id);

        if(review.getImage_list() != null && !review.getImage_list().isBlank()){
            review.setImgList(Arrays.asList(review.getImage_list().split(",")));
        }

        model.addAttribute("review", review);

        return "review/review_modify";

    }

    //레시피 수정
    @PostMapping("/review/modify")
    @ResponseBody
    public Map<String,Object> reviewModifyFin(ReviewVO review, String deleteImages){

        Map<String,Object> map =  new HashMap<>();
        

        ImgVO img = imgDAO.img_select(review.getImg_id());
        
        if(img == null) {
            map.put("review_res", 0);
            map.put("text","음.. img 널값이야");
            return map;
        }

        List<String> imageList= new ArrayList<>(Arrays.asList(img.getImage_list().split(",")));        
        List<String> deleteList = new ArrayList<>(Arrays.asList(deleteImages.split(",")));
        
        imageList.removeAll(deleteList);

        review.setThumbnail(imageList.isEmpty() ? null : imageList.get(0));

        if(review.getPhoto() != null && !review.getPhoto().isEmpty()){
            try {
                String newImages = fileupload.saveFiles(review.getPhoto(), "review");

                imageList.addAll(Arrays.asList(newImages.split(",")));
                
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                map.put("img_res", 0);
                map.put("test", "img 저장 실패");
            }
        }
        
        img.setImage_list(String.join(",", imageList));

        int res = imgDAO.img_update(img);

        if( res > 0 ) {
            fileupload.deleteFiles(deleteImages, "review");
        }

        int review_res = reviewDao.reviewUpdate(review);

        map.put("img_res", res);
        map.put("review_res",review_res);

        return map;

    }

}
