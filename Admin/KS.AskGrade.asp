<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="Include/Session.asp"-->
<%dim channelid
Dim KSCls
Set KSCls = New Admin_Ask_Class
KSCls.Kesion()
Set KSCls = Nothing

Class Admin_Ask_Class
        Private KS,DataArry,TypeFlag
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		End Sub
		Public Sub Kesion()
        If Not KS.ReturnPowerResult(0, "WDXT10003") Then          '�����Ȩ��
					 Call KS.ReturnErr(1, "")
					 KS.Die ""
		 End If
		Dim Action,DataArry
		Action = LCase(Request("action"))
		TypeFlag=KS.ChkClng(KS.S("TypeFlag"))
		Select Case Trim(Action)
		Case "save"
			Call saveScore()
		Case Else
			Call showmain()
		End Select
		End Sub
		Sub showmain()
			Dim i,iCount,lCount
			iCount=2:lCount=1
		%>
		<html>
		<head>
		<link href="Include/Admin_Style.CSS" rel="stylesheet" type="text/css">
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<script src="../KS_Inc/common.js" language="JavaScript"></script>
		</head>
		<body>
		<div class='topdashed sort'><%IF TypeFlag=1 then response.write "��̳" else response.write "�ʰ�"%>�ȼ�ͷ������</div>
		<table id="tablehovered" border="0" align="center" cellpadding="3" cellspacing="1" width="100%">
		<form name="selform" id="selform" method="post" action="?">
		<input type="hidden" name="action" value="save">
		<input type="hidden" name="typeflag" value="<%=typeflag%>"/>
		<tr class='sort'>
			<td width="10%" noWrap="noWrap">�ȼ�ID</td>
			<td>�û��ȼ�ͷ��</td>
			<td noWrap="noWrap">��ɫ</td>
			<td noWrap="noWrap">ͼ��</td>
			<%if TypeFlag=1 then%>
			<td noWrap="noWrap">��̳������</td>
			<%end if%>
			<td noWrap="noWrap">���������</td>
			<%if typeflag=1 then%>
			<td noWrap="noWrap">�û���</td>
			<%end if%>
			<td width="15%" noWrap="noWrap">��������</td>
		</tr>
		<%
			Call showScoreList()
			iCount=1:lCount=2
			If IsArray(DataArry) Then
				For i=0 To Ubound(DataArry,2)
					If Not Response.IsClientConnected Then Response.End
		%>
		<tr align="center">
			<td class="splittd"><input type="hidden" name="GradeID" value="<%=DataArry(0,i)%>"><%=DataArry(0,i)%></td>
			<%if DataArry(5,i)="0" then%>
			<td class="splittd"><input type="text" size="20" name="UserTitle<%=DataArry(0,i)%>" value="<%=Server.HTMLEncode(DataArry(1,i))%>" /></td>
			<%else%>
			<td class="splittd"><%=Server.HTMLEncode(DataArry(1,i))%> (<font color=red>ϵͳ</font>)<input type="hidden" size="20" name="UserTitle<%=DataArry(0,i)%>" value="<%=Server.HTMLEncode(DataArry(1,i))%>" /></td>
			<%end if%>
			<td class="splittd"><input type="text" size="10" name="color<%=DataArry(0,i)%>" value="<%=DataArry(6,i)%>" /></td>
			<td class="splittd"><input type="text" size="10" name="ico<%=DataArry(0,i)%>" value="<%=DataArry(3,i)%>" /></td>
			<%if typeflag=1 then%>
			  <%if DataArry(5,i)="0" then%>
			<td class="splittd"><input type="text" size="8" name="ClubPostNum<%=DataArry(0,i)%>" value="<%=DataArry(4,i)%>" /></td>
			  <%else%>
			   <td class="splittd">---</td>
			 <%end if%>
			<%end if%>
			 <%if DataArry(5,i)="0" then%>
			<td class="splittd"><input type="text" size="15" name="Score<%=DataArry(0,i)%>" value="<%=DataArry(2,i)%>" /></td>
			  <%else%>
			   <td class="splittd">---</td>
			  <%end if%>
			  
			  <%if typeflag=1 then%>
			<td class="splittd">
			 <a href='KS.User.asp?UserSearch=14&ClubGradeID=<%=DataArry(0,i)%>'>
			<%=conn.execute("select count(1) from ks_user where clubgradeid=" & DataArry(0,i))(0)%> λ
			</a>
			</td>
			  <%end if%>
			<td class="splittd">
			<%if DataArry(5,i)="0" then%>
			 <a href="?x=c&typeflag=<%=typeflag%>&id=<%=DataArry(0,i)%>" onClick="return(confirm('ȷ��ɾ����?'))">ɾ��</a>
			<%else%>
			 <a href="#" disabled>ɾ��</a>
			<%end if%>			</td>
		</tr>
		<%
				Next
			End If
			DataArry=Null
		%>
		<tr align="center">
			<td class="tablerow<%=lCount%>" colspan="6">
				<input class="button" type="submit" name="submit_button" value="������������"/>			</td>
		</tr>
		</form>

		<form action="?x=b&typeflag=<%=typeflag%>" method="post" name="myform" id="form">
		    <tr>
			<td height="25" colspan="7">&nbsp;&nbsp;<strong>&gt;&gt;�����ȼ�ͷ��</strong><<</td>
		    </tr>
			<tr><td colspan=10 background='images/line.gif'></td></tr>
			<tr valign="middle" class="list"> 
			  <td height="25"></td>
			  <td height="25" align="center"><input name="UserTitle" type="text" class="textbox" id="UserTitle" size="25"></td>
			  <td align="center"><input style="text-align:center" name="color" type="text" value="#000000" class="textbox" id="color" size="10"></td>
			  <td align="center"><input style="text-align:center" name="rank" type="text" value="rank0.gif" class="textbox" id="rank" size="10"></td>
			  <td align="center"><input style="text-align:center" name="clubpostnum" type="text" value="100" class="textbox" size="10"></td>
			  <td height="25" align="center"><input style="text-align:center" name="Score" type="text" value="1000" class="textbox" id="Score" size="8">
��</td>
			  <td height="25" align="center"><input name="Submit3" class="button" type="submit" value="OK,�ύ"></td>
			</tr>
			<tr><td colspan=10 background='images/line.gif'></td></tr>
		</form>
		</table>
		<font color=red>˵���ȼ�ͼ��������club/imagesĿ¼�¡�</font>
		<%
		 Select case request("x")
		   case "b"
		       If KS.G("UserTitle")="" Then Response.Write "<script>alert('������ȼ�ͷ��!');history.back();</script>":response.end
			   If Not Isnumeric(KS.G("Score")) Then Response.Write "<script>alert('���ֱ���������!');history.back();</script>":response.end
			    Dim GradeID:GradeID=KS.ChkClng(Conn.Execute("Select Max(gradeid) From KS_AskGrade")(0))+1
			    If DataBaseType=1 Then  CONN.execute("SET IDENTITY_INSERT [KS_AskGrade] ON")
				conn.execute("Insert into KS_AskGrade(GradeID,UserTitle,score,ico,clubpostnum,typeflag,color)values(" & GradeID & ",'" & KS.G("UserTitle") & "','" & KS.ChkClng(KS.G("Score")) & "','" & KS.G("Rank") & "'," & KS.ChkClng(KS.G("clubpostnum")) &"," & typeflag &",'" & KS.S("Color") & "')")
				If DataBaseType=1 Then  CONN.execute("SET IDENTITY_INSERT [KS_AskGrade] Off")
				

				
				KS.AlertHintScript "��ϲ,�ȼ�ͷ�γɹ�!"
		   case "c"
				conn.execute("Delete from KS_AskGrade where GradeID="& KS.ChkClng(KS.G("id")))
				KS.AlertHintScript "��ϲ,�ȼ�ͷ��ɾ���ɹ�!"
		End Select
		  
		End Sub
		
		Sub showScoreList()
			Dim Rs,SQL
			SQL="SELECT GradeID,UserTitle,Score,Ico,ClubPostNum,Special,Color FROM [KS_AskGrade] Where TypeFlag=" & TypeFlag & " order by gradeid"
			Set Rs=Conn.Execute(SQL)
			If Not (Rs.BOF And Rs.EOF) Then
				DataArry=Rs.GetRows(-1)
			Else
				DataArry=Null
			End If
			Rs.close()
			Set Rs=Nothing
		End Sub
		
		Sub saveScore()
			Dim Rs,SQL,i
			Dim GradeID,UserTitle,Score,Ico,clubpostnum,Color
			    GradeID=Split(Replace(Request.Form("GradeID")," ",""),",")
                For I=0 To Ubound(GradeID)
				 UserTitle=Replace(Request.Form("UserTitle"&GradeID(I)),"'","")
				 Score=KS.ChkClng(Request.Form("Score"&GradeID(I)))
				 Ico=Request.Form("Ico"&GradeID(I))
				 Color=Request.Form("Color"&GradeID(I))
				 clubpostnum=KS.ChkClng(Request.Form("clubpostnum"&GradeID(I)))
				 If GradeID(I)>0 Then
					Conn.Execute ("UPDATE KS_AskGrade SET clubpostnum=" & clubpostnum &",Ico='" & Ico & "',UserTitle='"&UserTitle&"',Score="&Score&",Color='" & Color &"' WHERE GradeID="&GradeID(I))
				 End If
			   Next
			Call KS.AlertHintScript("��ϲ���������û����ֵȼ��ɹ�!")
		End Sub
End Class
%>