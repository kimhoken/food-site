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
import com.project.foodsite.dao.BoardDAO;
import com.project.foodsite.dto.AdminBoardDTO;
import com.project.foodsite.vo.MemberVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class AdminBoardController {

    private final HttpSession httpSession;
    private final BoardDAO boardDAO;
    private final AdminUtil adminUtil;

    // 게시글 페이징
    private void BoardPaging(Model model, AdminBoardDTO Board ){
        if(Board.getPage() <= 0){
            Board.setPage(1);
        }

        int totalcount = boardDAO.boardCount(Board);

        Paging paging = new Paging(Board.getPage(), 5, totalcount);

        Board.setOffset(paging.getOffset());
        Board.setSize(paging.getSize());

        List<AdminBoardDTO> list = boardDAO.BoardSearch(Board);
        
        model.addAttribute("list", list);
        model.addAttribute("totalcount", totalcount );
        model.addAttribute("paging", paging);
        model.addAttribute("adminboard", Board);

    }

    // 관리자 게시글 페이지
    @GetMapping("/admin/board")
    public String boardpage(Model model, AdminBoardDTO Board){
        
        MemberVO user = (MemberVO)httpSession.getAttribute("user");
        
        model.addAttribute("profileuser", user);        

        adminUtil.setContentPage(model, "board");

        BoardPaging(model, Board);

        return "member/adminpage";
    }

    // 게시글 상세 조회
    @PostMapping("/admin/board/view")
    @ResponseBody
    public AdminBoardDTO board_view(int board_id){

        return boardDAO.adminBoardDetail(board_id);
    }

    // 게시글 공개/비공개 설정
    @PostMapping("/admin/board/hidden")
    @ResponseBody
    public Map<String,Object> boardHidden( int board_id ) {

        AdminBoardDTO Board = boardDAO.adminBoardDetail(board_id);

        if (Board.getStatus().equals("ACTIVE") ){
            Board.setStatus("HIDDEN");
        } else if ( Board.getStatus().equals("HIDDEN")  ){
            Board.setStatus("ACTIVE");
        }

        int res = boardDAO.boardStatus(Board);

        Map<String,Object> map = new HashMap<>();

        map.put("result", res);
        map.put("status", Board.getStatus());

        return map;

    }

    // 게시글 삭제/ 복원
    @PostMapping("/admin/board/delete")
    @ResponseBody
    public Map<String,Object> boardDelete(int board_id){

        AdminBoardDTO Board = boardDAO.adminBoardDetail(board_id);

        if (Board.getStatus().equals("DELETE") ){
            Board.setStatus("ACTIVE");
        } else if ( Board.getStatus().equals("ACTIVE") || Board.getStatus().equals("HIDDEN") ){
            Board.setStatus("DELETE");
        }

        int res = boardDAO.boardStatus(Board);

        Map<String,Object> map = new HashMap<>();

        map.put("result", res);
        map.put("status", Board.getStatus());

        return map;

    }
}
