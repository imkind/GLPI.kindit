<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.MemberCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 4.5
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KSCls
Set KSCls = New SiteIndex
KSCls.Kesion()
Set KSCls = Nothing

Class SiteIndex
        Private KS, KSR,ListStr
		Private MaxPerPage, TotalPut , CurrentPage, TotalPage, i, j, Loopno
	    Private KeyWord, SearchType,GuestCheckTF,SqlStr
		Private Sub Class_Initialize()
		 If (Not Response.IsClientConnected)Then
			Response.Clear
			Response.End
		 End If
		  Set KS=New PublicCls
		  Set KSR = New Refresh
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		End Sub
		%>
		<!--#include file="../KS_Cls/Kesion.IfCls.asp"-->
        <!--#include file="../KS_Cls/ClubFunction.asp"-->
        <!--#include file="../KS_Cls/UbbFunction.asp"-->
		<%
		
		Public Sub Kesion()
			If KS.Setting(56)="0" Then response.write "��վ�ѹر����Թ���":response.end
			If KS.Setting(59)="0" Then response.redirect("index.asp")
			GuestCheckTF=KS.Setting(52)
			KeyWord = KS.CheckXSS(Trim(KS.S("keyword")))
			SearchType = KS.R(Trim(KS.S("SearchType")))
		    Dim FileContent,KMRFObj
			Set KMRFObj = New Refresh
		          If KS.Setting(114)="" Then KS.Die "���ȵ�""������Ϣ����->ģ���""����ģ��󶨲���!"
				   FileContent = KMRFObj.LoadTemplate(KS.Setting(114))
				   If Trim(FileContent) = "" Then FileContent = "ģ�岻����!"
				   GetClubPopLogin FileContent
				   FCls.RefreshType = "guestindex" '����ˢ�����ͣ��Ա�ȡ�õ�ǰλ�õ�����
				   FCls.RefreshFolderID = "0" '���õ�ǰˢ��Ŀ¼ID Ϊ"0" ��ȡ��ͨ�ñ�ǩ
				   Call GetList()
				   FileContent=Replace(FileContent,"{$GetGuestList}",ListStr & PageList())
				   FileContent=Replace(FileContent,"{$PageStr}","")
				   FileContent=Replace(FileContent,"{$GuestTitle}","��վ����")
				   FileContent=Replace(FileContent,"{$PostButtonAction}","<a href=""" & KS.Setting(3) & KS.Setting(66) & "/post.asp""><img src=""" & KS.Setting(3) & KS.Setting(66) & "/images/button_post.png"" align=""absmiddle"" alt=""����""></a>")
				   FileContent=KSR.KSLabelReplaceAll(FileContent)
				   KS.Echo RexHtml_IF(FileContent)
		End Sub
		
	  Sub GetList()
		 Dim RSObj:Set RSObj=Server.CreateObject("Adodb.RecordSet")
		 Dim Param
		 If KS.ChkClng(GuestCheckTf)=0 Then
		 Param=" where deltf=0"
		 Else
		 Param=" where deltf=0 and verific=1"
		 END iF
		 If KeyWord<>"" Then
		   If SearchType="1" Then
		    Param=Param & " and subject like '%" & keyword & "%'"
		   Else
		    Param=Param & " and username like '%" & keyword & "%'"
		   End If
		 End If
		 
		
		SqlStr = "SELECT * From KS_GuestBook " & Param & " ORDER BY ID DESC" 
			
	RSObj.Open SqlStr,Conn,1,1
	
	Dim Pmcount:Pmcount = KS.Setting(51)
	If KS.ChkClng(Pmcount) < 1 Then Pmcount = 10

	RSObj.Pagesize = Pmcount
	TotalPut = RSObj.RecordCount	'��¼���� 
	TotalPage = RSObj.PageCount	    '�õ���ҳ��
	MaxPerPage = RSObj.PageSize	    '����ÿҳ��
		
	CurrentPage = KS.ChkClng(KS.S("Page"))
	
	If CDbl(CurrentPage) < 1 Then CurrentPage = 1
	If CDbl(CurrentPage) > CDbl(TotalPage) Then CurrentPage = TotalPage

	If RSObj.Eof or RSObj.Bof Then 
		ListStr = "<div style='color:#FF0000;margin:10px;text-align:center;border:1px solid #efefef;height:50px;line-height:50px'>��ʱ��û���κ����ԣ�</div>"
	Else
		RSObj.Absolutepage = CurrentPage	'��ָ������ָ��ҳ�ĵ�һ����¼
		Loopno = MaxPerPage
		i = 0
Do While Not RSObj.Eof and Loopno > 0
          ListStr = ListStr & " <table width='100%' border='1' cellspacing='0' cellpadding='2' align='center' bordercolordark='#FFFFFF' bordercolorlight='#DDDDDD' style='table-layout:fixed;word-break:break-all;font-family: Arial, Helvetica, sans-serif;'>" & vbcrlf
          ListStr = ListStr & " <tr>"
          ListStr = ListStr & "<td width='100' align='center' bgcolor='#F5F5F5' rowspan='3' ><font face='Arial, Helvetica, sans-serif'>��<font color='#FF0000'>" & ((TotalPut)-(MaxPerPage)*(CurrentPage-1))-i & "</font>������<br><img src='../images/Face/" & RSObj("Face") & "'><br></font>" &vbcrlf
          ListStr = ListStr & " <table width='98%'  border='0' align='center' cellpadding='0' cellspacing='0' bgcolor='#FFFFFF'>" & vbcrlf
          ListStr = ListStr & "                       <tr>"
          ListStr = ListStr & "                        <td align='center' bgcolor='#F5F5F5'><font face='Arial, Helvetica, sans-serif'>"& RSObj("UserName") & "</font></td></tr></table></td>" & vbcrlf
          ListStr = ListStr & "                <td height='25' valign='middle'><table width='100%' border='0' cellspacing='0' cellpadding='0'>" & vbcrlf
          ListStr = ListStr & "                    <tr>"
          ListStr = ListStr & "                      <td width='49%'><img src='../editor/ubb/images/smilies/default/" & replace(RSObj("TxtHead"),"Face.gif","01.gif") & "' align='absmiddle'> ���⣺" & RSObj("Subject") & "</td><td width='51%' align='right'>" & vbcrlf
		    If RSObj("HomePage") <> "" and RSObj("HomePage") <> "http://" Then
          ListStr = ListStr & "      <a href='" & RSObj("HomePage") & "' target='_blank'><img src='images/home.gif' width='16' height='16' border='0' align='absmiddle' alt='��ҳ:[ " & RSObj("HomePage") & " ]'></a>"
            Else
          ListStr = ListStr & "      <a href='#'><img src='images/home-gray.gif' width='16' height='16' border='0' align='absmiddle' alt='��ҳ'></a>" &vbcrlf
            End If
             ListStr = ListStr & "                     |" 
             If RSObj("Email") <> "" Then
           ListStr = ListStr & "                       <a href='mailto:" & RSObj("Email") & "' target='_blank'><img src='images/email.gif' width='18' height='18' border='0' align='absmiddle' alt='�����ʼ�:[ " & RSObj("Email") &" ]'></a>" & vbcrlf
             Else
           ListStr = ListStr & "                       <a href='#'><img src='images/email-gray.gif' width='18' height='18' border='0' align='absmiddle' alt='�����ʼ�'></a>" & vbcrlf
            End If
             ListStr = ListStr & "                     |" 
            If RSObj("Oicq") <> "" and RSObj("Oicq") <> "0" Then
            ListStr = ListStr & " <a href='#'><img src='images/qq.gif' width='16' height='16' border='0' align='absmiddle' alt='QQ����:[ " & RSObj("Oicq") & " ]'></a>"
            Else
            ListStr = ListStr & "  <a href='#'><img src='images/qq-gray.gif' width='16' height='16' border='0' align='absmiddle' alt='QQ����'></a>" & vbcrlf
            End If
             ListStr = ListStr & "                     |" 
             If RSObj("GuestIP") <> "" Then
            ListStr = ListStr & " <a href='#'><img src='images/ip.gif' width='16' height='16' border='0' align='absmiddle' alt='���ԣ�[ " & RSObj("GuestIP") & " ]'></a>" & vbcrlf
             Else
            ListStr = ListStr & " <a href='#'><img src='images/ip-gray.gif' width='16' height='16' border='0' align='absmiddle' alt='���ԣ�'></a>" & vbcrlf
            End If
             ListStr = ListStr & "                     &nbsp; </td>"
             ListStr = ListStr & "                 </tr>"
             ListStr = ListStr & "             </table></td>"
             ListStr = ListStr & "           </tr>"
             ListStr = ListStr & "           <tr>"
             ListStr = ListStr & "             <td>" 
			 
			 Dim Content,RSC:Set RSC=Conn.Execute("select top 1 Content From " & rsobj("postTable") & " Where parentid=0 and topicid=" & rsobj("id"))
			 if not rsc.eof then
			   content=rsc(0)
			   content=UbbCode(KS.CheckScript(KS.HtmlCode(content)),0)
			 end if
			 set rsc=nothing
			 if RSObj("purview")="1" Then
				 If KS.C("AdminName")<>"" or KS.C("UserName")=RSObj("UserName") Then
				  ListStr = ListStr & content
				 Else
				  ListStr = ListStr & "<div style=""width:350px;height:35px;line-height:30px;margin : 5px 20px; border : 1px solid #efefef; padding : 5px;background : #ffffee; line-height : normal;""><br/>�Բ��𣬴��������ݱ��������趨������Ա�ɼ���</div>"
				 End If
			 Else
				  ListStr = ListStr & content
			 End If
			 
			 ListStr = ListStr & " </td></tr>" & vbcrlf
             ListStr = ListStr & "           <tr><td height='20' align='right'>����ʱ�䣺" & RSObj("AddTime") & "&nbsp; </td></tr>" & vbcrlf
			 Dim RS:Set RS=Server.CreateObject("adodb.recordset")
			 rs.open "select top 1 content,replaytime,txthead from " & rsobj("postTable") &" where parentid<>0 and topicid=" & rsobj("id"),conn,1,1
			 if not rs.eof then
             ListStr = ListStr & "           <tr>"
             ListStr = ListStr & "             <td width='100' align='center' bgcolor='#F5F5F5'>����ظ���</td>" & vbcrlf
             ListStr = ListStr & "             <td><img src='../editor/ubb/images/smilies/default/" & rs(2) & ".gif' align='absmiddle'>&nbsp;<font color=red>" & KS.HtmlCode(RS(0)) & "</font><div align=right>�ظ�ʱ�䣺&nbsp;" & Rs(1) & "</div></td></tr>"
             End If
			 rs.close:set rs=nothing
             ListStr = ListStr & "         </table><br>" & vbcrlf

	RSObj.MoveNext
	Loopno = Loopno-1
	i = i+1
	Loop
End if
	RSObj.Close:Set RSObj=Nothing
 End Sub
 
 Function PageList()
    PageList=  KS.ShowPage(totalput, MaxPerPage, "", CurrentPage,false,false)
 End Function
					  
End Class
%>