<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 7.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
response.cachecontrol="no-cache"
response.addHeader "pragma","no-cache"
response.expires=-1
response.expiresAbsolute=now-1
Response.CharSet="gb2312" 
Dim KSCls
Set KSCls = New UserLogin
KSCls.Kesion()
Set KSCls = Nothing

Class UserLogin
        Private KS
		Private KSUser,Action
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser = New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub
		Public Sub Kesion()
		 Action=KS.S("Action")
		 If Action="script" Then
		  Call GetLoginByScript()
		  Exit Sub
		 ElseIf Action="checklogin" Then
		  Call CheckUserIsLogin()
		  Exit Sub
		 ElseIf Action="PoploginStr" Then
		  GetPoploginStr()
		  Exit Sub
		 End If
		%>
		<html>
<head>
<title>会员登录</title>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<style type="text/css">
<!--
.textbox
{
BACKGROUND-COLOR: #ffffff;
BORDER: #ccc 1px solid;
COLOR: #999;
HEIGHT: 22px;
line-height:22px
border-color: #666666 #666666 #666666 #666666; font-size: 9pt;FONT-FAMILY: verdana
}
TD
{
FONT-FAMILY:宋体;FONT-SIZE: 9pt;line-height: 130%;
}
a{text-decoration: none;} /* 链接无下划线,有为underline */
a:link {color: #000000;} /* 未访问的链接 */
a:visited {color: #333333;} /* 已访问的链接 */
a:hover{COLOR: #AE0927;} /* 鼠标在链接上 */
a:active {color: #0000ff;} /* 点击激活链接 */
.logintitle{font-size:14px;color:#336699;font-weight:bold}
#PopLogin td{font-size:14px;line-height:180%}
#PopLogin td a{color:#336699;text-decoration:underline}
#PopLogin td span{color:#5F5C67;font-size:13px}
#PopLogin td input{margin:2px}
.btn{border-color:#3366cc;margin-right:1em;color:#fff;background:#3366cc;}
.btn{border-width:1px;cursor:pointer;padding:.1em 1em;*padding:0 1em;font-size:9pt; line-height:130%; overflow:visible;}
-->
</style>
<script language="javascript">
//if(self==top){self.location.href="index.asp";}
function CheckForm(){
	var username=document.myform.Username.value;
	var pass=document.myform.Password.value;
	if (username=='')
	{
	  alert('请输入用户名!');
	  document.myform.Username.focus();
	  return false;
    }
	if (pass=='')
	{
	  alert('请输入登录密码!');
	  document.myform.Password.focus();
	  return false;
	 }
	 <% If KS.Setting(34)="1" Then%>
	 if (document.myform.Verifycode.value==''){
	  alert('请输入验证码!');
	  return false;
	 }
	 <%End If%>
	 return true;
}
function getCode(){
 document.getElementById('showVerify').innerHTML='<IMG style="cursor:pointer" src="../plus/verifycode.asp?n="<%=Timer%>" onClick="this.src=\'../plus/verifycode.asp?n=\'+ Math.random();" align="absmiddle">';
}
</script>

</head>
<body leftmargin="0" topmargin="0" style="background-color:transparent;<%If KS.S("Action")="Poplogin" then response.write "background:url(images/loginbg.png) repeat-x;"%>">
		<%
		If KS.S("Action")="Top" Then
		   Call Login1()
		ElseIf KS.S("Action")="Poplogin" Then
		   Call PopLogin()
		Else
		   Call Login2()
		 End If
		End Sub
		
		'script方式调用
		Sub GetLoginByScript()
           If KSUser.UserLoginChecked=false Then
		    KS.Echo "document.write('<form name=""myform"" id=""myform"" method=""POST"" action=""" & KS.GetDomain & "user/checkuserlogin.asp"">用户名 <input type=""text"" maxlength=""30"" name=""username"" id=""username"" size=""12"" class=""textbox""/>&nbsp;密码 <input style=""FONT-FAMILY: verdana;"" type=""password"" maxlength=""30"" name=""password"" size=""12"" id=""password"" class=""textbox""/>&nbsp;');"
			 If KS.Setting(34)="1" Then
			  KS.Echo "document.write('<span>验证码 </span><input onFocus=""getCode()"" maxlength=""8"" type=""text"" name=""Verifycode"" size=""5"" class=""textbox""><span id=""showVerify""><IMG style=""cursor:pointer"" src=""" & KS.GetDomain & "plus/verifycode.asp"" onClick=""this.src=\'" & KS.GetDomain & "plus/verifycode.asp?n=\'+ Math.random();"" align=""absmiddle""></span>');"
			 End If
			 KS.Echo "document.write('<input align=""absmiddle"" type=""image"" src=""" & KS.GetDomain & "images/login.gif"" onclick=""return(CheckLoginForm())""  class=""lgbtn""/>&nbsp;<a href=""" & KS.GetDomain & "?do=reg"" target=""_self"">注册</a>&nbsp;|&nbsp;<a href=""" & KS.GetDomain & "user/getpassword.asp"">找回密码</a></form>');"
		   Else
		     KS.Echo "document.write('您好！<span style=""color:red"">" & KSUser.UserName & "</span>,欢迎来到会员中心!【<a href=""" & KS.GetDomain & "user/"">会员中心</a>】【<a href=""" & KS.GetDomain & "/user/user_Message.asp?action=inbox"">短消息"& GetMailTips()& "</a>】【<a href=""" & KS.GetDomain & "User/UserLogout.asp"">退出</a>】');"
		   End If
		End Sub
		
		Sub CheckUserIsLogin()
		  If KSUser.UserLoginChecked=false Then
		    If KS.S("S")="1" Then
		     KS.Echo "var user={'loginstr':'您好,欢迎进入" & KS.Setting(0) & "! [<a href=""javascript:void(0)"" onclick=""ShowPopLogin()"">登录</a>] | [<a href=""" & KS.GetDomain & "?do=reg"" target=""_blank"">免费注册</a>]'}"
			Else
			 KS.Echo "var user={'loginstr':'<form name=""myform"" id=""myform"" method=""POST"" action=""" & KS.GetDomain & "user/checkuserlogin.asp"">用户名 <input type=""text"" maxlength=""30"" name=""username"" id=""username"" size=""12"" class=""textbox""/>&nbsp;密码 <input style=""FONT-FAMILY: verdana;"" type=""password"" maxlength=""30"" name=""password"" size=""12"" id=""password"" class=""textbox""/>&nbsp;"
			 If KS.Setting(34)="1" Then
			  KS.Echo "<span>验证码 </span><input onFocus=""getCode()"" maxlength=""8"" type=""text"" name=""Verifycode"" size=""5"" class=""textbox""><span id=""showVerify""><IMG style=""cursor:pointer"" src=""" & KS.GetDomain & "plus/verifycode.asp"" onClick=""this.src=\'" & KS.GetDomain & "plus/verifycode.asp?n=\'+ Math.random();"" align=""absmiddle""></span>"
			 End If
			 KS.Echo "<input align=""absmiddle"" type=""image"" src=""" & KS.GetDomain & "images/login.gif"" onclick=""return(CheckLoginForm())""  class=""lgbtn""/>&nbsp;<a href=""" & KS.GetDomain & "?do=reg"" target=""_self"">注册</a>&nbsp;|&nbsp;<a href=""" & KS.GetDomain & "user/getpassword.asp"">找回密码</a></form>'}"
			End If
		  Else
		    KS.Echo "var user={'loginstr':'您好！<span style=""color:red"">" & KSUser.UserName & "</span>,欢迎来到会员中心!【<a href=""" & KS.GetDomain & "user/"">会员中心</a>】【<a href=""" & KS.GetDomain & "/user/user_Message.asp?action=inbox"">短消息"& GetMailTips()& "</a>】【<a href=""" & KS.GetDomain & "User/UserLogout.asp"">退出</a>】'}"
		  End If
		End Sub
		
		
		Function GetMailTips()
		    Dim MyMailTotal:MyMailTotal=Conn.Execute("Select Count(ID) From KS_Message Where Incept='" &KSUser.UserName &"' And Flag=0 and IsSend=1 and delR=0")(0)
			'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_BlogMessage Where UserName='" &KSUser.UserName &"' And readtf=0")(0)
			'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_BlogComment Where UserName='" &KSUser.UserName &"' And readtf=0")(0)
			'MyMailTotal=MyMailTotal+Conn.Execute("Select Count(ID) From KS_Friend Where Friend='" &KSUser.UserName &"' And accepted=0")(0)
			 IF MyMailTotal>0 Then 
			  GetMailTips="<font color=""red"">" & MyMailTotal & "</font><bgsound src=""" & KS.GetDomain & "User/images/mail.wav"" border=0>"  
			  Else
			  GetMailTips=0
			 End If
		End Function
		
		Sub PopLogin()
		%>
		 <table id="PopLogin" width="100%" height="184" cellpadding="0" cellspacing="0" border="0">
		  <tr>
		   <td>
		     <table border="0" width="95%" align="center">
			   <form action="checkuserlogin.asp" method="post" name="myform">
			  <tr>
			   <td style="border-right:solid 1px #cccccc">
			    没有账号？<a href="../?do=reg" target="_blank">现在注册</a><br/>
				密码忘了, <a href="<%=KS.Setting(3)%>user/getpassword.asp"  target="_blank">我要找回</a> <br />
			   </td>
			   <td>
			      <div class="logintitle">用户登录</div>
				  <span>用户账号：</span><input type="text" name="Username" class="textbox"><br />
				  <span>登录密码：</span><input type="password" name="Password" class="textbox"><br/>
				  <% If KS.Setting(34)="1" Then%>
				  <span>附加字符：</span><input onFocus="getCode()" type="text" name="Verifycode" size="5" class="textbox"><span id='showVerify'></span><br/>
				  <%end if%>
				  <input type="hidden" name="Action" value="PopLogin">
				  <input type="submit" value=" 登 录 " class="btn" onClick="return(CheckForm())"  name="submit">
				   <input name="ExpiresDate" type="checkbox" id="ExpiresDate" value="checkbox">	<span>永久登录</span>
			   </td>
			  </tr>
				 </form>
			 </table>
		   </td>
		  </tr>
		 </table>
		<%
		End Sub
		
		'给$.getScript弹出窗口用
		Sub GetPoploginStr()
		 Dim Str
		 str="<table id=""PopLogin"" style=""font-size:14px;line-height:180%"" width=""100%"" height=""184"" cellpadding=""0"" cellspacing=""0"" border=""0""><tr><td><table border=""0"" width=""95%"" align=""center""><tr><td style=""border-right:solid 1px #cccccc"">没有账号？<a href=""" & KS.GetDomain & "?do=reg"" target=""_blank"">现在注册</a><br/>密码忘了, <a href=""" & KS.GetDomain &"user/getpassword.asp""  target=""_blank"">我要找回</a> <br /></td><td style=""text-align:left""><div style=""font-size:14px;color:#336699;font-weight:bold"" class=""logintitle"">用户登录</div><span>用户账号：</span><input type=""text"" name=""Username"" class=""textbox""><br /><span>登录密码：</span><input type=""password"" name=""Password"" class=""textbox""><br/>"
		 If KS.Setting(34)="1" Then
		 str=str &"<span>附加字符：</span><input onFocus=""getCode()"" type=""text"" name=""Verifycode"" size=""5"" class=""textbox""><span id=""showVerify""></span><br/>"
		 End If
		 Str=Str & "<input type=""submit"" onclick=""return(CheckLoginForm())"" value="" 登 录 "" name=""submit""><input name=""ExpiresDate"" type=""checkbox"" id=""ExpiresDate"" value=""checkbox"">	<span>永久登录</span></td></tr></table></td></tr></table>"
         KS.Die "var userpop={""str"":'" & str & "'}"
		End Sub
		
		Sub Login1()
			If KSUser.UserLoginChecked() = False Then
			%>
				<table cellspacing="0" cellpadding="0" width="99%" border="0">
				<form name="myform" action="<%=KS.GetDomain%>User/CheckUserLogin.asp?Action=Top" method="post">
								<tr>
								  <td>用户名：<input class="textbox" size="10" name="Username" />  密 码：<input class="textbox" type="Password" size="10" name="Password"><%if KS.Setting(34)=1 Then%>验证码：<input name="Verifycode" type="text" class="textbox" id="Verifycode" size="6" /><%
				Response.Write "<IMG style=""cursor:pointer"" src=""" & KS.GetDomain & "plus/verifycode.asp?n=" & Timer & """ onClick=""this.src='" & KS.GetDomain & "plus/verifycode.asp?n='+ Math.random();"" align=""absmiddle"">"
				end if%> 
								    <input name="loginsubmit" type="image"  onClick="return(CheckForm())" src="<%=KS.GetDomain%>images/login.gif" align="top" />
								    &nbsp;<a href="<%=KS.GetDomain%>?do=reg" target="_blank"><img src="<%=KS.GetDomain%>images/reg.gif"  border="0" align="absmiddle" twffan="done" /></a></td>
								</tr>
							</table>
			<%Else

			%>
			<table cellspacing="0" cellpadding="0" width="99%" border="0">
				<tr>
			     <td height="22" align="center">您好!<font color=red><%=KSUser.UserName%></font>,欢迎来到会员中心!&nbsp;【<a href="<%=KS.GetDomain%>User/index.asp?User_Message.asp?action=inbox" target="_parent">收信箱 <%=GetMailTips()%></a>】&nbsp;【<a href="<%=KS.GetDomain%>User/index.asp" target="_parent">会员中心</a>】&nbsp;【<a href="<%=KS.GetDomain%>User/UserLogout.asp">退出登录</a>】</td>
				</tr>
			</table>
<%End IF
		End Sub
		Sub Login2()
			If KSUser.UserLoginChecked() = False Then
			%>
			<table align="center" width="98%" border="0" cellspacing="0" cellpadding="0">
			 <form name="myform" action="CheckUserLogin.asp" method="post">
			  <tr>
				<td height="25">用户名：
				<input name="Username" type="text" class="textbox" id="Username" size="15"></td>
			  </tr>
			  <tr>
				<td height="25">密　码：
				<input name="Password" type="password" class="textbox" id="Password" size="16"></td>
			  </tr>
			  <%if KS.Setting(34)=1 Then%>
			  <tr>
				<td height="25">验证码：
				<input name="Verifycode" onClick="getCode()" type="text" class="textbox" id="Verifycode" size="6">
				<span id='showVerify'></span>
				</td>
			  </tr>
			  <%end if%>
			  <tr>
				<td height="25"><div align="center"><img src="<%=KS.GetDomain%>images/losspass.gif" align="absmiddle"> <a href="<%=KS.GetDomain%>User/GetPassword.asp" target="_parent">忘记密码</a> <img src="<%=KS.GetDomain%>images/mas.gif" align="absmiddle"> <a href="<%=KS.GetDomain%>?do=reg" target="_parent">新会员注册</a>    </div></td>
			  </tr>
			  <tr>
				<td height="25"><div align="center">
				  <input type="submit" name="Submit"  onClick="return(CheckForm())" class="inputButton" value="登录">

				  <input name="ExpiresDate" type="checkbox" id="ExpiresDate" value="checkbox">
			永久登录</div></td>
			  </tr>
			  </form>
            </table>
			<%Else
			 dim  ChargeTypeStr
			 if KSUser.ChargeType=1 Then
			   ChargeTypeStr="扣点"
			 elseif KSUser.ChargeType=2 Then
			   ChargeTypeStr="有效期"
			 else
			   ChargeTypeStr="无限期"
			 End If
			%>
			<table align="center" style="margin-top:5px" width="80%" border="0" cellspacing="0" cellpadding="0">
			<tr><td align="center"><font color=red><%=KSUser.UserName%></font>,
           <%
			If (Hour(Now) < 6) Then
            Response.Write "<font color=##0066FF>凌晨好!</font>"
			ElseIf (Hour(Now) < 9) Then
				Response.Write "<font color=##000099>早上好!</font>"
			ElseIf (Hour(Now) < 12) Then
				Response.Write "<font color=##FF6699>上午好!</font>"
			ElseIf (Hour(Now) < 14) Then
				Response.Write "<font color=##FF6600>中午好!</font>"
			ElseIf (Hour(Now) < 17) Then
				Response.Write "<font color=##FF00FF>下午好!</font>"
			ElseIf (Hour(Now) < 18) Then
				Response.Write "<font color=##0033FF>傍晚好!</font>"
			Else
				Response.Write "<font color=##ff0000>晚上好!</font>"
			End If
			%>&nbsp;&nbsp;&nbsp;</td></tr>
			<tr><td>计费方式： <strong><%= ChargeTypeStr%></strong> </td></tr>
			<tr><td>经验积分： <strong><%=KSUser.GetUserInfo("Score")%></strong> 分</td></tr>
			<%if KSUser.ChargeType=1 or KSUser.ChargeType=2 then%>
			<% if KSUser.ChargeType=1 then%>
			<tr><td>可用点券： <strong><%=KSUser.GetUserInfo("Point")%></strong> 点</td></tr>
			<%else%>
			<tr><td>剩余天数： <strong><%=KSUser.GetEdays%></strong></td></tr>
			<%end if%>
			<%end if%>
			<tr><td>待阅短信： <strong><%=GetMailTips()%></strong> 条</td></tr>
			<tr><td>登录次数： <strong><%=KSUser.GetUserInfo("LoginTimes")%></strong> 次</td></tr>
            <tr><td nowrap="nowrap">【<a href="<%=KS.GetDomain%>User/index.asp" target="_parent">会员中心</a>】【<a href="<%=KS.GetDomain%>User/UserLogout.asp">退出登录</a>】</td></tr>
			</table>
<%End IF
  End Sub
End Class
%>

 
