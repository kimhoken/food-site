package com.project.foodsite.controller;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.project.foodsite.common.MailSendService;
import com.project.foodsite.common.NicknameGenerater;
import com.project.foodsite.common.pwdSecurity;
import com.project.foodsite.dao.MemberDAO;
import com.project.foodsite.dao.TokenDAO;
import com.project.foodsite.vo.MemberVO;
import com.project.foodsite.vo.TokenVO;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class memberController {

   
    private final HttpSession httpSession;

    private final MemberDAO memberDAO;
    private final MailSendService mss;
    private final pwdSecurity pwdSecurity;
    private final NicknameGenerater nicknameGenerater;
    private final TokenDAO tokenDAO;
  

    
    // 로그인 페이지
    @GetMapping("/login.do")
    public String loginpage() {
        return "member/login";
    }

    // 로그인
    @PostMapping("/login.do")
    @ResponseBody
    public Map<String, Object> loginCheck(MemberVO vo) {
        MemberVO user = memberDAO.getUserById(vo.getLogin_id());
        Map<String, Object> map = new HashMap<>();
        String login_res = "no_id";

        if (user != null) {
            login_res = "no_pwd";
            boolean pwdcheck = pwdSecurity.pwdDecoding(vo.getPassword(),user.getPassword()); 

            if (pwdcheck) {
                if("SUSPEND".equals(user.getStatus())){
                
                    if (user.getSuspend_end().after(new Date())){
                        map.put("res", "suspend");
                        map.put("day", user.getSuspend_end().toString());

                        return map;
                    }

                    memberDAO.relaseSuspend(user.getMember_id());

                    user.setStatus("ACTIVE");
                    user.setSuspend_end(null);
                    user.setSuspend_start(null);

                }

                httpSession.setAttribute("user", user);
                httpSession.setMaxInactiveInterval(3600);
                map.put("nick", user.getNickname());
                login_res = "login";
            }
        }
        map.put("res", login_res);
        return map;
    }

    // 회원 가입 페이지
    @GetMapping("/register_form.do")
    public String registerpage(Model model) {
        boolean sys=true;
        String nickname = "no_name";
        MemberVO socialUser = (MemberVO) httpSession.getAttribute("socialUser");

        if(socialUser != null){
            model.addAttribute("socialUser", socialUser);
            model.addAttribute("isSocial", true);
            if(socialUser.getNickname() != null){
                nickname = socialUser.getNickname();
                sys = false;
            }
        }else{
            model.addAttribute("isSocial", false);
        }
        
        while(sys){
            nickname = nicknameGenerater.createnickname(); 
            MemberVO vo = memberDAO.getUserNickname(nickname);
            if(vo == null){
                sys=false;
            }  
        }
        model.addAttribute("nickname",nickname);
        return "member/register_form";
    }

    //회원가입 
    @PostMapping("/register.do")
    @ResponseBody
    public Map<String, Integer> register(MemberVO vo) throws Exception {
        if(vo.getLogin_type() == null){
            vo.setLogin_type("LOCAL");
        }
        
        if(vo.getPassword() != null && !vo.getPassword().isEmpty()){
            // 비밀번호 암호화
            String enc_pwd = pwdSecurity.pwdEncoding(vo.getPassword());
            vo.setPassword(enc_pwd);            
        }
        
        if(vo.getFilename() == null  ){
            String filename = "no_file.png";
            vo.setFilename(filename);
        }

        vo.setMember_intro("안녕하십니까 "+vo.getName()+" 입니다.");
        vo.setRole("USER");
        vo.setStatus("ACTIVE");

        int res = memberDAO.userInsert(vo);

        Map<String, Integer> map = new HashMap<>();
        map.put("res", res);
        return map;
    }

    //아이디 중복 검사
    @PostMapping("/check_id.do")
    @ResponseBody
    public Map<String,String> checkId(String login_id){
        MemberVO vo = memberDAO.getUserById(login_id);
        String id_msg="yes";

        if(vo != null ){            
            id_msg="no";
        }

        Map<String,String> map = new HashMap<>();

        map.put("id_msg", id_msg);
        map.put("id", login_id);
        return map;

    }

    //비밀번호 유효성 및 확인 함수
    @PostMapping("/pwd_check.do")
    @ResponseBody
    public Map<String,String> check_pwd( String pwd, String pwd_check){
        String regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*]).{10,}$";
        String pwd_msg = "";
        String pwd_check_msg = "";

        if(!pwd.matches(regex)){
            pwd_msg = "no";
        }else{
            pwd_msg = "yes";
        }

        if(!pwd.equals(pwd_check) || pwd.length() < 10){
            pwd_check_msg = "no";
        }else{
            pwd_check_msg = "yes";
        }

        Map<String,String> map = new HashMap<>();
        map.put("pwd_msg", pwd_msg);
        map.put("pwd_check_msg", pwd_check_msg);

        return map;

    }

    //인증 번호 메일 전송 함수
    @PostMapping("/mail_check.do")
    @ResponseBody
    public Map<String,String> emailCheck(String email) {
        String res = mss.sendEmail(email,"authnumber");
        Map<String,String> map = new HashMap<>();

        map.put("authNumber", res);
        return map;       
    }

    //닉네임 중복 검사 함수
    @PostMapping("/check_nickname.do")
    @ResponseBody
    public Map<String,String> nicknameCheck(String nickname){
        MemberVO vo = memberDAO.getUserNickname(nickname);
        String nickname_msg = "";

        if(vo != null){
            nickname_msg = "yes";
        }else{
            nickname_msg = "no";
        }

        Map<String,String> map = new HashMap<>();

        map.put("nickname_msg", nickname_msg);
        map.put("nickname", nickname);

        return map;
    }

    //아이디, 비밀번호 찾기 페이지
    @GetMapping("/find.do")
    public String findpage(String select, Model model){
        model.addAttribute("select",select);
        return "member/findpage";
    }

    //회원 이메일 존재 여부 함수
    @PostMapping("/emailfind.do")
    @ResponseBody
    public Map<String,String> findemail(String email){
        MemberVO vo = memberDAO.getUserEmail(email);
        String res = "no";

        if(vo != null){
            res = "yes";
        }

        Map<String,String> map = new HashMap<>();

        map.put("email",email);
        map.put("result",res);

        return map;
    }

    // 이메일로 회원 정보 조회
    @PostMapping("/findid.do")
    @ResponseBody
    public String findid(String email){
        MemberVO vo = memberDAO.getUserEmail(email);
        return vo.getLogin_id();
    }

    //이메일 재설정 링크 보내는 함수
    @PostMapping("/resetpwd.do")
    @ResponseBody
    public Map<String,String> resetpwd(String email, String login_id){
        MemberVO membervo = memberDAO.getUserEmail(email);
        Map<String,String> map = new HashMap<>();

        // 이메일과 아이디로 membervo 같은지 판별
        if(!membervo.getLogin_id().equals(login_id)){
            map.put("result", "fail");
            return map;
        }

        String res = mss.sendEmail(email, "resetpwd");
        TokenVO vo = new TokenVO();

        vo.setMember_id(membervo.getMember_id());
        vo.setToken(res);
        vo.setExpire_date(LocalDateTime.now().plusMinutes(30));

        int msg_res = tokenDAO.insertToken(vo);

        if(msg_res > 0){
            map.put("result", "success");
        }else{
            map.put("result", "fail");
        }

        return map;
    }

    //비밀번호 재설정 페이지 전송 함수
    @GetMapping("/resetpwd.do")
    public String resetpwd_form(String token, Model model){
        TokenVO vo = tokenDAO.getToken(token);

        if(vo != null){
            if(vo.getExpire_date().isBefore(LocalDateTime.now()) || vo.getUsed().equals("yes")){
                model.addAttribute("msg", "토큰이 만료되었습니다.");                
            }

            MemberVO membervo = memberDAO.getUserByMemberId(vo.getMember_id());
            model.addAttribute("member" , membervo);
            model.addAttribute("token" , vo);
            
        }else{
            model.addAttribute("msg", "토큰이 존재하지 않습니다.");
        }

        return "member/resetpwd_form";
    }   

    //비밀번호 재설정 함수
    @PostMapping("/repwd.do")
    @ResponseBody
    public String repwd(int member_id, String password, int token_id){
        String enc_pwd = pwdSecurity.pwdEncoding(password);
        MemberVO vo = new MemberVO();

        vo.setMember_id(member_id);
        vo.setPassword(enc_pwd);
        
        int res = memberDAO.userPwdUpdate(vo);
        
        if(res > 0){
            //재설정 완료후 토큰 삭제
            tokenDAO.deletetoken(token_id);
            return "success";
        }else{
            return "fail";
        }
    }
    
    
}
