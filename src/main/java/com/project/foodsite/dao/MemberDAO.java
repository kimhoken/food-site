package com.project.foodsite.dao;

import java.util.List;


import com.project.foodsite.dto.AdminMemberDTO;
import com.project.foodsite.dto.MemberDTO;
import com.project.foodsite.vo.MemberVO;

public interface MemberDAO {
    
    int userInsert(MemberVO vo);
        
    MemberVO getUser( MemberDTO member );

    MemberVO getUserByMemberId(int member_id);

    int userPwdUpdate(MemberVO vo);

    int userUpdate(MemberVO vo);

    MemberVO getSocialUser(String provider,String provider_id);

    int secessionUser( MemberVO vo);

    int memberCount();

    List<MemberVO> MemberSearch( AdminMemberDTO admin );

    AdminMemberDTO memberDetail( int member_id );

    int relaseSuspend( int member_id );
    
} 