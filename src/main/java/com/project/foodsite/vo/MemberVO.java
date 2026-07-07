package com.project.foodsite.vo;



import java.util.Date;

import org.apache.ibatis.type.Alias;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Alias("member")
public class MemberVO {
    private String login_id, password, nickname, email, 
    role, status, profile_img, login_type, provider, provider_id, name, member_intro, created_date;
    private int member_id, report_count;

    private Date suspend_start, suspend_end;

    private MultipartFile photo;
    private String filename;
}
