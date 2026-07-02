package com.project.foodsite.controller;

import java.util.*;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.multipart.MultipartFile;

import com.project.foodsite.common.Fileupload;
import com.project.foodsite.dao.BoardDAO;
import com.project.foodsite.dao.CommonCommentDAO;
import com.project.foodsite.dao.RecipeDAO;
import com.project.foodsite.dao.ReviewDAO;
import com.project.foodsite.vo.BoardVO;
import com.project.foodsite.vo.CategoryVO;
import com.project.foodsite.vo.CookOrderVO;
import com.project.foodsite.vo.FoodVO;
import com.project.foodsite.vo.IngredientVO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.ReviewVO;

import lombok.RequiredArgsConstructor;

import com.project.foodsite.dto.RecipeDTO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.ResponseBody;


@Controller
@RequiredArgsConstructor
public class BoardController {

    private final BoardDAO boardDao;
    private final HttpSession session;
    private final ReviewDAO reviewDao;
    private final Fileupload fileupload;
    private final CommonCommentDAO commonCommentDAO;

    // board list 조회
    @GetMapping("/list.do")
    public String boardList(Model model, String sort, String period, String btn) {

        // 레시피 후기 탭의 조회
        List<ReviewVO> reviewList = reviewDao.reviewLatest();
        model.addAttribute("reviewList", reviewList);
        // 정렬조건이 없을경우
        if (sort == null || sort.isEmpty()) {
            sort = "all";
        }

        if (sort.equals("rating")) {
            reviewList = reviewDao.reviewRating();
        } else if (sort.equals("popular")) {
            reviewList = reviewDao.reviewPopular(period);
        } else {
            reviewList = reviewDao.reviewLatest();
        }

        model.addAttribute("list", boardDao.selectAll());
        model.addAttribute("reviewList", reviewList);

        model.addAttribute("sort", sort);
        model.addAttribute("period", period);
        model.addAttribute("btn", btn);
        return "board/board_list";
    }

    // board 검색
    @PostMapping("/search.do")
    public String boardSearch(Model model, String search) {
        List<BoardVO> list = boardDao.search(search);

        model.addAttribute("list", list);
        model.addAttribute("searchWord", search); // 검색어 보관
        return "board/board_list";
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    // --------------이거 전체 레시피쪽으로 가서 수정해야함----------------------

    /* recipe 등록 */

    // recipe 등록 폼
    @GetMapping("/regiRecipe.do")
    public String recipeForm(Model model, String id) {
        model.addAttribute("id", id);
        model.addAttribute("bigList", categoryDAO.getCategoryName());
        return "board/board_regiRecipe";
    }

    // 내 레시피 등록하기
    @PostMapping("/myrecipe.do")
    public String registerRecipe(RecipeDTO dto) throws Exception {

        String filename = fileupload.saveFile(dto.getMainImg(), "recipe");

        dto.setThumbnail(filename);

        // 등록 데이터 잘 들어오는지 확인용

        System.out.println("대표이미지 : " + dto.getMainImg().getOriginalFilename());

        System.out.println("선택한 foodId = " + dto.getFoodId());
        System.out.println("생성된 recipeId = " + dto.getRecipeId());
        System.out.println("insert 후 recipeId = " + dto.getRecipeId());
        System.out.println("insert 후 foodId = " + dto.getFoodId());

        System.out.println("제목 : " + dto.getTitle());

        System.out.println("재료명 : " + dto.getIngredientName());
        System.out.println("수량 : " + dto.getAmount());
        System.out.println("단위 : " + dto.getUnit());

        System.out.println("조리순서 : " + dto.getStep());

        System.out.println(dto.getMemberId());
        System.out.println(dto.getRecipeId());

        // 조리시간 변환
        switch (dto.getCooking_time()) {
            case "10":
                dto.setCooking_time("10분");
                break;
            case "20":
                dto.setCooking_time("20분");
                break;
            case "30":
                dto.setCooking_time("30분");
                break;
            case "60":
                dto.setCooking_time("60분");
                break;
        }

        // 1. 레시피테이블에 레시피 등록
        boardDao.insertRecipe(dto);

        // 2. ingredient 저장
        for (int i = 0; i < dto.getIngredientName().size(); i++) {

            IngredientVO ingredient = new IngredientVO();

            ingredient.setIngredient_name(
                    dto.getIngredientName().get(i));

            ingredient.setQuantity(
                    Long.parseLong(dto.getAmount().get(i)));

            ingredient.setUnit(dto.getUnit().get(i));

            ingredient.setRecipe_id(dto.getRecipeId().intValue());

            boardDao.insertIngredient(ingredient);
        }

        // 3. 조리과정 저장
        for (int i = 0; i < dto.getStep().size(); i++) {

            CookOrderVO order = new CookOrderVO();

            order.setOrder(i + 1);
            order.setDescription(dto.getStep().get(i));
            order.setRecipe_id(dto.getRecipeId().intValue());

            // 파일 저장
            MultipartFile img = dto.getStepImg().get(i);

            if (img != null && !img.isEmpty()) {
                String cookOrderImg = fileupload.saveFile(img, "recipe");

                order.setCook_image(cookOrderImg);
            }

            // 조리시간 들어오는지 확인
            System.out.println("조리시간 : " + dto.getCooking_time());

            boardDao.insertCookOrder(order);
        }

        return "redirect:/recipe_list.do";
    }

    /**
     * 레시피테이블에 제목이랑 썸네일 이미지 등록 후 방금 등록한 레시피 ID가져오기
     * 재료테이블에 재료를 넣고, 조리순서 테이블에 조리순서, 이미지를 넣어 아까 만든 레시피 ID와 연결
     * 게시판 테이블에 레시피ID, member_id를 참조하게 하고 제목, 내용 넣기
     */

    // 여기서 부터 커뮤니티 상세보기

    @GetMapping("/view.do")
    public String boardView(int board_id, Model model, HttpServletRequest req) {

        @SuppressWarnings("unchecked")
        HashMap<String, LinkedList<Integer>> map = session.getAttribute("viewMap") == null ? new HashMap<>()
                : (HashMap<String, LinkedList<Integer>>) session.getAttribute("viewMap");
        /*
         * // 세션에서 IP, 게시글 ID를 확인해 없을경우 조회수 증가
         * if (map.get(req.getRemoteAddr()) == null &&
         * !map.get(req.getRemoteAddr()).contains(board_id)) {
         * // 조회수 증가
         * boardDao.updateViewCount(board_id);
         * map.computeIfAbsent(req.getRemoteAddr(), k -> new
         * LinkedList<>()).add(board_id);
         * session.setAttribute("viewMap", map);
         * session.setMaxInactiveInterval(3600);
         * }
         */

        // 조회수 처리
        String ip = req.getRemoteAddr();

        LinkedList<Integer> viewedList = map.computeIfAbsent(ip, k -> new LinkedList<>());

        if (!viewedList.contains(board_id)) {

            boardDao.updateViewCount(board_id);

            viewedList.add(board_id);

            session.setAttribute("viewMap", map);
        }

        // 게시글 조회
        BoardVO board = boardDao.selectOne(board_id);


        model.addAttribute("board", board);

        // 커뮤니티 게시글에 달린 댓글 목록 조회
        model.addAttribute("commentList", commonCommentDAO.getBoardList(board_id));

        return "board/board_view";
    }

    // 상세보기 수정 폼
    @GetMapping("/update_form.do")
    public String updateForm(int board_id, HttpSession session, Model model) {
        BoardVO board = boardDao.selectOne(board_id);
        model.addAttribute("board", board);
        return "board/board_update";
    }

    // 상세보기 수정
    @PostMapping("/update.do")
    public String update(BoardVO vo) {
        boardDao.update(vo);
        return "redirect:/view.do?board_id=" + vo.getBoard_id();
    }

    // 상세보기 삭제
    @GetMapping("/delete.do")
    public String delete(int board_id, HttpSession session) {
        boardDao.selectOne(board_id);
        boardDao.delete(board_id);
        return "redirect:/list.do";
    }

    // 커뮤니티 글쓰기 폼
    @GetMapping("/community_form.do")
    public String communityForm() {
        return "board/community_form";
    }

    // 커뮤니티 글쓰기
    @PostMapping("/community_write.do")
    public String write(BoardVO vo, HttpSession session) {

        MemberVO user = (MemberVO) session.getAttribute("user");

        vo.setMember_id(user.getMember_id());

        vo.setBoard_type("COMMUNITY");
        vo.setRecipe_id(1);

        boardDao.insertBoard(vo);

        return "redirect:/list.do";
    }

    @PostMapping("/api/category")
    @ResponseBody
    public Map<?, ?> getCategory(@RequestBody Map<String, Object> map) {
        List<CategoryVO> list = categoryDAO.getSubName((String)map.get("category"));
        String res = list.size() > 0 ? "success" : "fail";
        map.put("list", list);
        map.put("result", res);
        return map;
    }
    
    @PostMapping("/api/food")
    @ResponseBody
    public Map<?, ?> getFood(@RequestBody Map<String, Object> map){
        List<FoodVO> list = categoryDAO.getFoodName((String)map.get("categoryId"));
        map.put("list", list);
        map.put("result", list.size() > 0 ? "success" : "fail");
        return map;
    }

}