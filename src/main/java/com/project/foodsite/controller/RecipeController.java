package com.project.foodsite.controller;

import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.project.foodsite.common.Fileupload;
import com.project.foodsite.dao.BoardDAO;
import com.project.foodsite.dao.CommonCommentDAO;
import com.project.foodsite.dao.RecipeDAO;
import com.project.foodsite.dao.SearchLogDAO;
import com.project.foodsite.dto.RecipeDTO;
import com.project.foodsite.dto.RecipeDetailDTO;
import com.project.foodsite.dto.RecipeSearchDTO;
import com.project.foodsite.util.SearchLog;
import com.project.foodsite.vo.CookOrderVO;
import com.project.foodsite.vo.IngredientVO;
import com.project.foodsite.vo.RecipeVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeDAO recipeDao;
    private final HttpSession session;
    private final SearchLogDAO searchLogDAO;
    private final BoardDAO boardDAO;
    private final CommonCommentDAO commonCommentDAO;
    private final SearchLog log;
    private final Fileupload fileupload;

    @GetMapping("/recipe_list.do")
    public String recipeList(RecipeSearchDTO searchDTO, Model model) {
        String category = searchDTO.getCategory();

        // 1. 카테고리 미선택 시 빈 상태 반환
        if (category == null || category.isEmpty()) {
            model.addAttribute("recipeList", new ArrayList<>());
            model.addAttribute("totalPage", 0);
            model.addAttribute("recipeSearchDTO", searchDTO);
            model.addAttribute("emptyMsg", "카테고리에서 목록을 선택후 조회해주세요!");
            return "recipe/recipe_list";
        }

        if (searchDTO.getSort() == null || searchDTO.getSort().isEmpty()) {
            searchDTO.setSort("latest");
        }

        int totalCount = recipeDao.selectRecipeCount(searchDTO);
        model.addAttribute("totalPage", (totalCount + 8) / 9);

        List<RecipeVO> recipeList = recipeDao.selectRecipeList(searchDTO);

        // 조리시간 출력 확인용
        for (RecipeVO recipe : recipeList) {
            System.out.println(recipe.getTitle());
            System.out.println(recipe.getCooking_time());
        }

        String sort = searchDTO.getSort();

        if (sort.equals("name")) {
            Collections.sort(recipeList, (e1, e2) -> {
                return e1.getTitle().compareTo(e2.getTitle());
            });

        }else if (sort.equals("view")) {
            Collections.sort(recipeList, (e1, e2) -> {
                return e2.getView_count() - e1.getView_count();
            });

        }else if (sort.equals("like")) {
            Collections.sort(recipeList, (e1, e2) -> {
                return e2.getLike_count() - e1.getLike_count();
            });

        }else {
            // 등록일자가 같을 경우 이름순으로 정렬
            Collections.sort(recipeList, (e1, e2) -> {
                if (e1.getCreated_date().compareTo(e2.getCreated_date()) == 0) {
                    return e2.getTitle().compareTo(e1.getTitle());
                }
                return e2.getCreated_date().compareTo(e1.getCreated_date());
            });
        }

        int offSet = searchDTO.getOffset();
        int start = 1;
        List<RecipeVO> resultList = new LinkedList<>();

        /*
         * 10 20 30 40 50 60 61
         * 조리시간이 선택되었을 경우 시간 사이인 것만 선택
         */
        List<String> times = searchDTO.getCookTimes();
        List<RecipeVO> timeList = null;
        if (times != null && !times.isEmpty()) {
            Queue<Integer> queue = new LinkedList<>();
            timeList = new LinkedList<>();
            for (String val : times) {
                // 선택된 것을 큐에 차례대로 담음
                queue.add(Integer.parseInt(val));
            }
            while (!queue.isEmpty()) {
                int minute = queue.poll();
                int min = minute - 10;
                for (RecipeVO vo : recipeList) {
                    if (minute == 61 && vo.getMin() >= minute - 1) {
                        timeList.add(vo);
                        continue;
                    }
                    if (vo.getMin() >= min && vo.getMin() <= minute) {
                        timeList.add(vo);
                    }
                }
            }
        }

        if (offSet != 9) {
            start = offSet - 8;
        }
        /*
         * page == 1 -> offSet = 9
         * page == 2 -> offSet = 18(10 ~ 18)
         * page == 3 -> offSet = 27(19 ~ 27)
         */
        for (int i = start; i <= offSet; i++) {
            if (timeList != null) {
                if (timeList.size() <= i)
                    break;
                resultList.add(timeList.get(i));
            } else {
                if (recipeList.size() <= i) {
                    break;
                }
                resultList.add(recipeList.get(i));
            }
        }

        if (resultList.size() == 0) {
            model.addAttribute("emptyMsg", "선택한 조건에 맞는 레시피가 없습니다....");
        }

        model.addAttribute("recipeList", resultList);
        model.addAttribute("recipeSearchDTO", searchDTO);
        model.addAttribute("sort", sort);

        // 데이터가 꽤 많아지면 용량을 많이 차지하므로 해제해 용량 확보
        recipeList = null;
        return "recipe/recipe_list";
    }

    /**
     * 레시피 검색
     * 
     * @param model  binding을 위한 model
     * @param search 검색어
     * @return jsp
     */
    @PostMapping("/search_recipe.do")
    public String recipeSearch(Model model, String search, HttpServletRequest req, String select) {
        // 검색어를 입력받아 검색어로 유사 검색 후 결과 리턴
        // 최근검색어는 큐로 저장해 5개 유지 및 오래된 검색어 삭제
        // 검색어를 받아 검색어 테이블에 저장

        // ip를 키, 검색어를 value로 저장
        @SuppressWarnings("unchecked")
        HashMap<String, List<String>> map = session.getAttribute("searchMap") == null ? new HashMap<>()
                : (HashMap<String, List<String>>) session.getAttribute("searchMap");

        // IP가 같은 키 값이 없을 경우
        if (!map.containsKey(req.getRemoteAddr())) {
            searchLogDAO.insertKeyWord(search);
            map.computeIfAbsent(req.getRemoteAddr(), k -> new ArrayList<>()).add(search);
            // 세션에 저장
            session.setAttribute("searchMap", map);
            session.setMaxInactiveInterval(3600);
        } else {
            boolean flag = true;
            for (String val : map.get(req.getRemoteAddr())) {
                if (val.equals(search)) {
                    flag = false;
                    break;
                }
            }

            // 맵에서 value가 search랑 같은 값이 없을 경우
            if (flag) {
                searchLogDAO.insertKeyWord(search);
                map.computeIfAbsent(req.getRemoteAddr(), k -> new ArrayList<>()).add(search);
                // 세션에 저장
                session.setAttribute("searchMap", map);
                session.setMaxInactiveInterval(3600);
            }
        }

        @SuppressWarnings("unchecked")
        Queue<String> searchQueue = (Queue<String>) session.getAttribute("searchQueue") == null ? new LinkedList<>()
                : (Queue<String>) session.getAttribute("searchQueue");

        // 겹치는 단어를 큐의 맨 뒤로 보냄
        for (String val : searchQueue) {
            if (val.equals(search)) {
                searchQueue.remove(search);
                break;
            }
        }

        if (searchQueue.size() >= 5) {
            // 크기가 5이상이면 가장 먼저 검색한 검색어 삭제
            searchQueue.poll();
        }

        searchQueue.add(search);

        // 기존 세션의 값 삭제
        session.removeAttribute("searchQueue");

        // 세션에 값을 새로 저장
        session.setAttribute("searchQueue", searchQueue);
        session.setAttribute("searchWord", search);
        session.setAttribute("select", select);

        log.getSearchLog();

        if (select.equals("review")) {
            model.addAttribute("list", boardDAO.search(search));
            return "board/board_list";
        } else {
            model.addAttribute("recipeList", recipeDao.search(search));
        }

        return "recipe/recipe_list";
    }

    /**
     * 레시피 상세정보 조회
     * 
     * @param model    binding을 위한 파라미터
     * @param recipeId 레시피조회를 위한 ID
     * @return jsp
     */
    @GetMapping("/recipe_detail.do")
    public String recipeDetail(Model model, @RequestParam(value = "recipe_id", required = false) Integer recipe_id, HttpServletRequest req) {

        if (recipe_id == null) {
            return "redirect:/recipe_list.do";
        }

        model.addAttribute("recipe_id", recipe_id);
        RecipeDetailDTO dto = recipeDao.getRecipe(recipe_id);

        //조회수 증가
        //IP를 키, 레시피 아이디를 value로 저장
        @SuppressWarnings("unchecked")
        Map<String, List<Integer>> map = session.getAttribute("viewMap") == null ? new HashMap<>()
                : (Map<String, List<Integer>>) session.getAttribute("viewMap");
        
        //맵에 ip자체가 없을 경우 또는 ip가 키값으로 있지만 value 리스트에 recipe_id가 없을 경우
        if(!map.containsKey(req.getRemoteAddr()) || !map.get(req.getRemoteAddr()).contains(recipe_id) ){
            //검색의 편의를 위해 arrayList 사용
            map.computeIfAbsent(req.getRemoteAddr(), k -> new ArrayList<>()).add(recipe_id);
            recipeDao.updateViewCount(recipe_id);
        }

        List<IngredientVO> ilist = dto.getIngredientList();
        List<CookOrderVO> olist = dto.getCookOrderList();

        Collections.sort(olist, (e1, e2) -> {
            return e1.getOrder() - e2.getOrder();
        });

        session.setAttribute("viewMap", map);
        session.setMaxInactiveInterval(3600);

        model.addAttribute("commentList", commonCommentDAO.getRecipeList(recipe_id));
        model.addAttribute("dto", dto);
        model.addAttribute("orderList", olist);
        model.addAttribute("ingredients", ilist);
        model.addAttribute("size", ilist.size());
        return "recipe/recipe_detail";
    }

    // 레시피 삭제
    @GetMapping("/recipe_delete.do")
    public String deleteRecipe(int recipeId) {
        recipeDao.deleteRecipe(recipeId);
        return "redirect:/recipe_list.do";
    }

    // 레시피 수정 폼
    // 수정 버튼 -> recipe_update.do -> recipe_update.jsp
    @GetMapping("/recipe_update.do")
    public String updateForm(int recipeId, Model model) {

        RecipeDetailDTO dto = recipeDao.getRecipe(recipeId);

        model.addAttribute("dto", dto);
        model.addAttribute("ingredients", dto.getIngredientList());
        model.addAttribute("orderList", dto.getCookOrderList());
        model.addAttribute("foodList", recipeDao.selectAllFood());

        return "recipe/recipe_update";
    }

    // 레시피 수정
    @PostMapping("/recipe_update.do")
    public String updateNewRecipe(RecipeDTO dto) throws Exception {

        // 1. 대표 이미지
        if (dto.getMainImg() != null && !dto.getMainImg().isEmpty()) {
            String filename = fileupload.saveFile(dto.getMainImg(), "recipe");
            dto.setThumbnail(filename);
        }

        // 2. 조리시간 변환
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
            case "61":
                dto.setCooking_time("60분 이상");
                break;
        }

        // 3. recipe 수정
        recipeDao.updateNewRecipe(dto);

        // 4. 기존 재료 삭제
        recipeDao.deleteIngredient(dto.getRecipeId().intValue());

        // 5. 재료 다시 저장
        for (int i = 0; i < dto.getIngredientName().size(); i++) {

            IngredientVO ingredient = new IngredientVO();

            ingredient.setIngredient_name(dto.getIngredientName().get(i));
            ingredient.setQuantity(Long.parseLong(dto.getAmount().get(i)));
            ingredient.setUnit(dto.getUnit().get(i));
            ingredient.setRecipe_id(dto.getRecipeId().intValue());

            boardDAO.insertIngredient(ingredient);
        }

        // 6. 기존 조리순서 삭제
        recipeDao.deleteCookOrder(dto.getRecipeId().intValue());

        // 7. 조리순서 다시 저장
        for (int i = 0; i < dto.getStep().size(); i++) {

            CookOrderVO order = new CookOrderVO();

            order.setOrder(i + 1);
            order.setDescription(dto.getStep().get(i));
            order.setRecipe_id(dto.getRecipeId().intValue());

            MultipartFile img = dto.getStepImg().get(i);

            if (img != null && !img.isEmpty()) {
                String cookOrderImg = fileupload.saveFile(img, "recipe");
                order.setCook_image(cookOrderImg);
            }

            boardDAO.insertCookOrder(order);
        }

        return "redirect:/recipe_detail.do?recipe_id=" + dto.getRecipeId();
    }
}
