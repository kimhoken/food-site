package com.project.foodsite.dao;

import java.util.List;
import java.util.Map;

import com.project.foodsite.vo.BoardVO;
import com.project.foodsite.vo.ReportVO;

public interface ReportDAO {

    int reportInsert(ReportVO vo);

    List<ReportVO> reportList();

    BoardVO selectBoardForReport(Integer board_id);

    ReportVO selectRecipeForReport(Integer recipe_id);

    ReportVO selectReviewForReport(Integer review_id);

    ReportVO selectCommentForReport(Integer comment_id);

    ReportVO selectReportOne(Integer report_id);

    Integer selectReportedMemberId(ReportVO vo);

    int updateMemberReportCount(Integer member_id);

    int updateReportStatusWarning(Integer report_id);

    int sameMemberSameTargetPendingReportCount(ReportVO vo);

    int updateSameMemberSameTargetReportStatusWarning(ReportVO vo);

    int reportCount();

    List<ReportVO> reportListPage(Map<String, Object> map);

    int reportDelete(int report_id);
}