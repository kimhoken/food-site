package com.project.foodsite.dto;

import java.util.List;

import org.apache.ibatis.type.Alias;

import com.project.foodsite.vo.ReportVO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@AllArgsConstructor
@NoArgsConstructor
@Alias("adminmember")
public class AdminMemberDTO extends SearchDTO {
    private String nickname, email, login_id, name, role, created_date, profile_img, memberintro, provider;
    private int member_id, report_count, recipe_count, like_count, bookmark_count, comment_count;
    private List<ReportVO> reportList;
}
