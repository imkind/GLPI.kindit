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
Dim KSCls
Set KSCls = New User_Upfile
KSCls.Kesion()
Set KSCls = Nothing

Class User_Upfile
        Private KS,KSUser,ChannelID,BasicType,UploadCode
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		  Set KSUser=New UserCls
		End Sub
        Private Sub Class_Terminate()
		 Call CloseConn()
		 Set KS=Nothing
		 Set KSUser=Nothing
		End Sub


		Public Sub Kesion()
		With Response
		.Write "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.01 Transitional//EN"">"
		.Write "<html>"
		.Write "<head>"
		.Write "<meta http-equiv=""Content-Type"" content=""text/html; charset=gb2312"">"
		.Write "<title>上传文件</title>"
		.Write "<link rel=""stylesheet"" href=""images/css.css"">"
		 %>
		 <script type="text/javascript">
		 function  doSubmit(obj){
		  	 LayerPrompt.style.visibility='visible';
			 UpFileForm.submit();
		 }
	     </script>
		 <%
		.Write "<style type=""text/css"">" & vbCrLf
		.Write "<!--" & vbCrLf
		.Write "body {"
		.Write "    margin-left: 0px; " & vbCrLf
		.Write "    margin-top: 0px;" & vbCrLf
		.Write "}" & vbCrLf
		.Write " #uploadImg{  overflow:hidden; position:absolute} " & vbcrlf
		.Write " .file{ cursor:pointer;position:absolute; z-index:100; margin-left:-180px; font-size:55px;opacity:0;filter:alpha(opacity=0); margin-top:-5px;}  " 
		.Write "-->" & vbCrLf
		.Write "</style></head>"
		.Write "<body class=tdbg style=""background-color:transparent"">"
		IF Cbool(KSUser.UserLoginChecked)=false Then
		 .write "<font size='2'>对不起,请先登录后才能使用此功能!</font>"
		 ' .Write "<script>top.location.href='Login';<//script>"
		  Exit Sub
		End If
		
		Randomize
		UploadCode = Int(900*rnd)+1000
		Session("UploadCode") = Cstr(UploadCode)

		ChannelID=KS.ChkClng(KS.S("ChannelID"))
		If ChannelID=999 Then
		 BasicType=ChannelID
		ElseIf ChannelID<5000 Then
		 BasicType=KS.C_S(ChannelID,6)
		Else
		 BasicType=ChannelID
		End If

       If KS.S("Type")="Field" Then
	     Call User_Field_UpForm
	   Else
			Select Case BasicType
			 Case 9999  '用户头像
			   Call User_face_UpForm
			 Case 9998  '相册封面
			   Call User_XPFM_UpForm
			 Case 9997  '相册照片
			   Call User_ZP_UpForm
			 Case 9996  '圈子图片
			   Call User_Team_UpForm
			 Case 9995  '上传mp3
			   Call User_Mp3_UpForm
			 case 9994  '小论坛上传数据
			   Call User_Club_UpFile
			 case 9993  '写日志附件上传数据
			   Call User_Club_UpFile
			 Case 999
			   Call User_UpForm()
			 Case 1
			   If KS.S("Type")="File" Then
				 Call User_Article_UpFile
			   Else
				 Call User_Article_UpForm
			   End IF
			 Case 2
			   Call UploadPhotoForm
			 Case 3
				If KS.S("Type")="Pic" Then
				 Call User_Down_Photo_UpForm
				Else
				 Call User_Down_File_UpForm
				End If
			 Case 4
			   If KS.S("Type")="Pic" Then
				Call UploadPhotoForm
			   Else
				Call User_Flash_File_UpForm
			   End If
			 Case 5
			   If KS.S("Type")="File" Then
			    Call User_Article_UpFile
			   Else
			     Call User_Shop_UpForm
			   End If
			 Case 7
			   If KS.S("Type")="Pic" Then
				Call UploadPhotoForm
			   Else
				Call User_Movie_File_UpForm
			   End If
			 Case 8
			   Call User_GQPhoto_UpForm
			 Case 9 
				  Call SJ_UpPhoto()
			End Select
		  End If
		 .Write "<div id=""LayerPrompt"" style=""position:absolute; z-index:1; left:2px; top: 0px; background-color: #ffffee; layer-background-color: #00CCFF; border: 1px solid #f9c943; width: 170px; height: 28px; visibility: hidden;"">"
		 .Write "  <table width=""100%"" height=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">"
		 .Write "    <tr>"
		 .Write "      <td><div>&nbsp;<img src='../images/default/wait.gif' align='absmiddle'></div></td>"
		 .Write "    </tr>"
		 .Write "  </table>"
		 .Write "</div>"
		End With
		End Sub
		
		'上传缩略图
		Sub UploadPhotoForm
		   With Response
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "  <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
			.Write "          <input type=""file"" class=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"">"
			.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地图片并上传..."">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input name=""Type"" value=""" & KS.S("Type") & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" Style=""display:none""><div style=""display:none"">同时生成缩略图</div>"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "添加水印</span>"
			.Write "    </form>"
			End With
		End Sub
		
		Sub User_Field_UpForm()
		 	With Response
			.Write "  <table width=""100%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr class='tdbg'>"
			.Write "        <td valign=""top"">上传：<input type=""file"" accept=""html"" size=""30"" name=""File1"" class='textbox'>"
			.Write "          <input type=""submit"" id=""BtnSubmit"" onclick=""LayerPrompt.style.visibility='visible';return(parent.CheckClassID())"" name=""Submit"" value=""开始上传"" class=""button"">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input name=""FieldID"" value=""" & KS.S("FieldID") & """ type=""hidden"">"
			.Write "          <input name=""Type"" value=""Field"" type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "          <span style='display:none'><input type=""checkbox"" name=""DefaultUrl"" value=""1"">"
			.Write "          缩略图"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"">"
			.Write "添加水印</span></td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End Sub
		
		'用户头像
		Sub User_Face_UpForm()
		  With Response
			.Write " <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write " <span id=""uploadImg"" >"
			'.Write "   <input type=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"" class='file'><input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""sbutton"" value=""选择电脑上的照片..."" style=""padding:4px"">"
			.Write "   <input type=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"" class='file'><button type=""submit"" id=""BtnSubmit"" class=""pn pnc"" style='_margin-top:-49px'><strong>选择电脑上的照片...</strong></button>"
            .wRITE "<input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "  </span>"
			.Write " </form>"
		 End With
		

		End Sub
        '相册封面
		Sub User_XPFM_UpForm()
			With Response
			.Write "  <table width=""100%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr class='tdbg'>"
			.Write "        <td valign=""top"">"
			.Write "          <input type=""file"" accept=""html"" size=""30"" name=""File1"" class=""textbox"">"
			.Write "          <input type=""submit"" id=""BtnSubmit"" onclick=""LayerPrompt.style.visibility='visible';"" class=""button"" name=""Submit"" value=""开始上传"">"
		    .Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			'.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" checked>"
			'.Write "          缩略图"
			'.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "</td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End Sub
		'圈子图片
		Sub User_Team_UpForm()
			With Response
			.Write "  <table width=""100%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr class='tdbg'>"
			.Write "        <td valign=""top"">"
			.Write "          <input type=""file"" onchange=""parent.document.all.showimages.src=this.value"" accept=""html"" size=""30"" name=""File1"" class=""textbox"">"
			.Write "          <input type=""submit"" id=""BtnSubmit"" onclick=""LayerPrompt.style.visibility='visible';"" class=""button"" name=""Submit"" value=""开始上传"">"
		    .Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			'.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" checked>"
			'.Write "          缩略图"
			'.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "</td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End Sub
		'Mp3
		Sub User_Mp3_UpForm()
			With Response
			.Write "  <table width=""100%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr class='tdbg'>"
			.Write "        <td valign=""top"">"
			.Write "          <input type=""file"" accept=""html"" size=""20"" name=""File1"" class=""textbox"">"
			.Write "          <input type=""submit"" id=""BtnSubmit"" onclick=""LayerPrompt.style.visibility='visible';"" class=""button"" name=""Submit"" value=""开始上传"">只支持MP3"
		    .Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "</td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End SUb
        '照片
		Sub User_ZP_UpForm()
			With Response
			.Write "<div align=""center"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "  <table width=""95%"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"">"
			.Write "      <tr>"
			.Write "        <td width=""82%"" valign=""top"">"
			.Write "          <div align=""center"">"
			.Write "            <table width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
			.Write "              <tr>"
			.Write "                <td width=""50%"" height=""50""> &nbsp;&nbsp;设定照片数量"
			.Write "                  <input class='textbox' name=""UpFileNum"" id=""UpFileNum"" type=""text"" value=""5"" size=""5"" style=""text-align:center"">"
			.Write "                <input type=""button"" name=""Submit42"" class=""button"" value=""确定设定"" onClick=""ChooseOption();""></td>"
			.Write "                <td width=""50%"" id='ss'>&nbsp;</td>"
			.Write "              </tr>"
			.Write "              <tr>"
			.Write "                <td height=""30"" colspan=""2"" id=""FilesList""> </td>"
			.Write "              </tr>"
			.Write "            </table>"
			.Write "        </div></td>"
			.Write "        <td width=""18%"" valign=""top"">"
			.Write "          <input name=""AddWaterFlag""  style=""display:none"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "<!--添加水印-->"
			.Write "        </td>"
			.Write "      </tr>"
			.Write "      <tr>"
			.Write "        <td  colspan=""2""> <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
			.Write "            <tr>"
			.Write "              <td align=""center"">"
			.Write "                  <input name=""AutoReName"" type=""hidden"" value=""4""><input type=""submit"" id=""BtnSubmit""  name=""Submit"" value=""开始上传"" onclick=""LayerPrompt.style.visibility='visible';"" class=""button"">"
		    .Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "                  <input type=""reset"" id=""ResetForm""  class=""button"" name=""Submit3"" value="" 重 填 "">"
			.Write "              </td>"
			.Write "            </tr>"
			.Write "          </table><font color=red>说明：只支持jpg、gif、png，小于100k的照片。</font></td>"
			.Write "      </tr>"
			.Write "  </table>"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "    </form>"
			.Write "</div>"
			.Write "<script language=""JavaScript""> " & vbCrLf
			.Write "function ViewPic(nid,f){" & vbcrlf
				.Write "if ( f != '' ) {" & vbcrlf
				.Write "  parent.document.getElementById('view'+nid).innerHTML='';" & vbcrlf
				.Write "  parent.document.getElementById('view'+nid).filters.item(""DXImageTransform.Microsoft.AlphaImageLoader"").src=f;" & vbcrlf
				.Write " }"
				.Write "}"
			.Write "function ChooseOption()" & vbCrLf
			.Write "{"
			.Write "  var UpFileNum = document.getElementById('UpFileNum').value;" & vbCrLf
			.Write "  if (UpFileNum=='') " & vbCrLf
			.Write "    UpFileNum=12;" & vbCrLf
			.Write "  var k,i,Optionstr,SelectOptionstr,n=0;" & vbCrLf
			.Write "      Optionstr = '<table width=""100%"" border=""0"" cellspacing=""5"" cellpadding=""0"">';" & vbCrLf
			.Write "  for(k=0;k<(UpFileNum/2);k++)" & vbCrLf
			.Write "   { " & vbCrLf
			.Write "    for (i=0;i<2;i++)" & vbCrLf
			.Write "      { n=n+1;" & vbCrLf
			.Write "       Optionstr = Optionstr+'<tr><td>&nbsp;照&nbsp;片&nbsp;'+n+'</td><td>&nbsp;<input type=""file"" accept=""html"" size=""35"" class=""textbox"" onchange=""ViewPic('+n+',this.value)"" name=""File'+n+'"">&nbsp;</td></tr>';" & vbCrLf
			.Write "        if (n==UpFileNum) break;" & vbCrLf
			.Write "       }" & vbCrLf
			.Write "      Optionstr = Optionstr+''" & vbCrLf
			.Write "  }" & vbCrLf
			.Write "    Optionstr = Optionstr+'</table>';" & vbCrLf
			.Write "    document.getElementById('FilesList').innerHTML = Optionstr;" & vbCrLf

			.Write "  var viewstr;"&vbcrlf
			.write "   n=0;"&vbcrlf
			.Write "   viewstr=""<table width='100%' border='0'>"";" &vbcrlf
			.write "   for(k=0;k<UpFileNum/5;k++)" & vbcrlf
			.write "    {" & vbcrlf
			.Write "     viewstr=viewstr+""<tr>"";" & vbcrlf
			.write "     for(i=0;i<5;i++)" & vbcrlf
			.write "      {" &vbcrlf
			.write "         n=n+1;"&vbcrlf
			.write "        viewstr=viewstr+""<TD width='20%'><div id='view""+n+""' name='view""+n+""' style='filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale);height:100px;width:120px;border:1px solid #ccc'><img src='../images/user/nopic.gif' width='120' height='100'></div> </TD>"";"&vbcrlf
			.Write "        if (n==UpFileNum) break;" & vbCrLf
			.write "       }"&vbcrlf
			.write "    for(i=n;i<5;i++)" & vbcrlf
			.write "     { viewstr=viewstr+""<td></td>"";}"
			.write "   viewstr=viewstr+""</tr>"";"&vbcrlf
			.Write "    }" & vbcrlf
			.write "  viewstr=viewstr+""</table>"";"&vbcrlf
			if KS.S("action")<>"OK" then	.write "parent.document.getElementById('viewarea').innerHTML=viewstr;"& vbcrlf
			.write "parent.init();"
			.write "parent.parent.init();"
			.Write " }" & vbCrLf
			.Write "ChooseOption();" & vbCrLf
			.Write "</script>" & vbCrLf
			End With
		End Sub
		
		Sub User_UpForm()
			With Response
			.Write "<div align=""center"">"
			.Write "  <table width=""95%"" border=""0"" align=""center"" cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr>"
			.Write "        <td width=""82%"" valign=""top"">"
			.Write "          <div align=""center"">"
			.Write "            <table width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
			.Write "              <tr>"
			.Write "                <td width=""50%"" height=""50""> &nbsp;&nbsp;设定文件数"
			.Write "                  <input class='textbox' name=""UpFileNum"" type=""text"" value=""3"" size=""5"" style=""text-align:center"">"
			.Write "                <input type=""button"" name=""Submit42"" class=""button"" value=""确定设定"" onClick=""ChooseOption();""></td>"
			.Write "                <td width=""50%"" id='ss' style='display:none'><input type=""checkbox"" name=""AutoReName"" value=""4"">自动命名</td>"
			.Write "              </tr>"
			.Write "              <tr>"
			.Write "                <td height=""30"" colspan=""2"" id=""FilesList""> </td>"
			.Write "              </tr>"
			.Write "            </table>"
			.Write "        </div></td>"
			.Write "        <td width=""18%"" valign=""top"">"
			.Write "          <input name=""AddWaterFlag""  style=""display:none"" type=""checkbox"" id=""AddWaterFlag"" value=""1"">"
			.Write "<!--添加水印-->"
			.Write "        </td>"
			.Write "      </tr>"
			.Write "      <tr>"
			.Write "        <td  colspan=""2""> <table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
			.Write "            <tr>"
			.Write "              <td align=""center"">"
			.Write "                  <input name=""AutoReName"" type=""hidden"" value=""4""><input type=""submit"" id=""BtnSubmit""  name=""Submit"" value=""开始上传"" onclick=""LayerPrompt.style.visibility='visible';"" class=""button"">"
		    .Write "          <input name=""BasicType"" value=""999"" type=""hidden"">"
			.Write "         <input type=""reset"" id=""ResetForm""  class=""button"" name=""Submit3"" value="" 重 填 "">"
			.Write "              </td>"
			.Write "            </tr>"
			.Write "          </table><font color=red>温馨提示：您只能上传jpg,gif,png,swf格式的文件。</font></td>"
			.Write "      </tr>"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "    </form>"
			.Write "  </table>"
			.Write "</div>"
			.Write "<script language=""JavaScript""> " & vbCrLf
			.Write "function ChooseOption()" & vbCrLf
			.Write "{"
			.Write "  var UpFileNum = document.all.UpFileNum.value;" & vbCrLf
			.Write "  if (UpFileNum=='') " & vbCrLf
			.Write "    UpFileNum=12;" & vbCrLf
			.Write "  var k,i,Optionstr,SelectOptionstr,n=0;" & vbCrLf
			.Write "      Optionstr = '<table width=""100%"" border=""0"" cellspacing=""5"" cellpadding=""0"">';" & vbCrLf
			.Write "  for(k=0;k<(UpFileNum/2);k++)" & vbCrLf
			.Write "   { " & vbCrLf
			.Write "    for (i=0;i<2;i++)" & vbCrLf
			.Write "      { n=n+1;" & vbCrLf
			.Write "       Optionstr = Optionstr+'<tr><td>&nbsp;文&nbsp;件&nbsp;'+n+'</td><td>&nbsp;<input type=""file"" accept=""html"" size=""35"" class=""textbox"" name=""File'+n+'"">&nbsp;</td></tr>';" & vbCrLf
			.Write "        if (n==UpFileNum) break;" & vbCrLf
			.Write "       }" & vbCrLf
			.Write "      Optionstr = Optionstr+''" & vbCrLf
			.Write "  }" & vbCrLf
			.Write "    Optionstr = Optionstr+'</table>';" & vbCrLf
			.Write "    document.all.FilesList.innerHTML = Optionstr;" & vbCrLf
			.Write "}ChooseOption();" & vbCrLf
			.Write "</script>" & vbCrLf
			End With
		End Sub
		
		Sub User_Article_UpForm()
		With Response
		.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
		.Write " <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
		.Write "          <input type=""file"" accept=""html"" onchange=""doSubmit()"" size=""1"" name=""File1"" class='file'>"
		.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地图片并上传...""><input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
		.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
		.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
		.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" checked>"
		.Write "          缩略图"
		.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>添加水印"
		.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
		.Write "         </span>"
		.Write "    </form>"
		End With
		End Sub
		'上传附件
		Sub User_Article_UpFile()
		  With Response
			.Write " <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write " <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
			.Write "   <input type=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"" class='file'><input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地附件并上传..."">"
            .wRITE "<input type=""hidden"" name=""AutoReName"" value=""0"">"
			.Write "<input name=""Type"" value=""File"" type=""hidden"">"
			.Write "<input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write " <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "  </span>"
			.Write " </form>"
		 End With
	 End Sub
		
		
		
		'上传下载缩略图
		Sub User_Down_Photo_UpForm()
			With Response
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "   <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
			.Write "          <input type=""file"" onchange=""doSubmit()"" accept=""html"" size=""1"" name=""File1"" class=""file"">"
			.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地图片..."">"
			.Write "          <input name=""UpLoadFrom"" value=""31"" type=""hidden"" id=""UpLoadFrom"">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input name=""Type"" value=""" & KS.S("Type") & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" Style=""display:none""><div style=""display:none"">同时生成缩略图</div>"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "添加水印</span>"
			.Write "    </form>"
			End With
		End Sub
		'上传下载文件
		Sub User_Down_File_UpForm
		With Response
		.Write " <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
		.Write "  <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
		.Write "    <input class=""file"" onchange=""doSubmit()"" type=""file"" accept=""html"" size=""1"" name=""File1""> "
		.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地软件..."">"
		.Write "                <input type=""hidden"" name=""AutoReName"" value=""4"" checked>"
		.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
		.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
		.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
		.Write "        </span>"
		.Write "    </form>"

		End With
		End Sub
		
		
		Sub User_Shop_UpForm
		  With Response
			.Write "  <table width=""95%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr>"
			.Write "        <td valign=""top"">"
			.Write "          <input type=""file"" class=""textbox"" accept=""html"" size=""30"" name=""File1"" class=""textbox"">"
			.Write "          <input type=""submit"" id=""BtnSubmit""  name=""Submit"" class=""button"" onclick=""LayerPrompt.style.visibility='visible';"" onmousedown=""return(parent.CheckClassID());"" value=""开始上传"">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input name=""Type"" value=""" & KS.S("Type") & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" checked>生成缩略图"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "添加水印</td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End Sub
		
		'上传动漫文件
		Sub User_Flash_File_UpForm
			With Response
			.Write "  <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "  <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
			.Write "   <input type=""file"" class=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"">"
			.Write "  <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地文件并上传..."">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "</span>"
			.Write "    </form>"
			End With
		End Sub
		
		
		'上传影片文件
		Sub User_Movie_File_UpForm
			With Response
			.Write "  <table width=""95%"" border=""0""  cellpadding=""0"" cellspacing=""0"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "      <tr>"
			.Write "        <td valign=""top"">"
			.Write "          <input type=""file"" class=""textbox"" accept=""html"" size=""40"" name=""File1"" class=""textbox"">"
			.Write "          <input type=""submit"" id=""BtnSubmit"" onclick=""LayerPrompt.style.visibility='visible';"" onmousedown=""return(parent.CheckClassID());"" name=""Submit""  class=""button"" value=""开始上传"">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "</td>"
			.Write "      </tr>"
			.Write "    </form>"
			.Write "  </table>"
			End With
		End Sub
		'供求图片
		Sub User_GQPhoto_UpForm()
			With Response
			.Write "<body class=tdbg onselectstart=""return false;"" oncontextmenu=""return false;"">"
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "    <span id=""uploadImg"" onmousedown=""return(parent.CheckClassID());"">"
			.Write "          <input type=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"" class=""file"">"
			.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择本地图片并上传..."">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" checked>"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "          缩略图"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""1"" checked>"
			.Write "添加水印</span>"
			.Write "    </form>"
			End With
		End Sub
		
		Sub Sj_UpPhoto()
		   With Response
			.Write "    <form name=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "  <span id=""uploadImg"">"
			.Write "          <input type=""file"" class=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"">"
			.Write "          <input type=""button"" id=""BtnSubmit"" name=""Submit"" class=""button"" value=""选择试卷并上传..."">"
			.Write "          <input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "          <input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "          <input name=""Type"" value=""" & KS.S("Type") & """ type=""hidden"">"
			.Write "          <input type=""hidden"" name=""AutoReName"" value=""4"">"
			.Write "          <input type=""checkbox"" name=""DefaultUrl"" value=""1"" Style=""display:none""><div style=""display:none"">"
			.Write "          <input name=""AddWaterFlag"" type=""checkbox"" id=""AddWaterFlag"" value=""0"" checked></div></span>"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "    </form>"
			End With


		End Sub
		
		
		'论坛上传附件
		Sub User_Club_UpFile()
		  With Response
			.Write " <form name=""UpFileForm"" id=""UpFileForm"" method=""post"" enctype=""multipart/form-data"" action=""UpFileSave.asp"">"
			.Write "   <span id=""uploadImg"">"
			.Write "   <input type=""file"" onchange=""doSubmit()"" size=""1"" name=""File1"" class='file'><input type=""button"" id=""BtnSubmit"" name=""Submit"" style=""padding:2px"" value=""选择附件上传..."">"
            .wRITE "<input type=""hidden"" name=""AutoReName"" value=""0"">"
			.Write "<input name=""Type"" value=""File"" type=""hidden"">"
			.Write "<input name=""BasicType"" value=""" & BasicType & """ type=""hidden"">"
			.Write "<input name=""ChannelID"" value=""" & ChannelID & """ type=""hidden"">"
			.Write "<input type=""hidden"" id=""UploadCode"" name=""UploadCode"" value=""" & UploadCode & """ />"
			.Write "<input name=""BoardID"" value=""" & KS.ChkClng(KS.S("BoardID")) & """ type=""hidden"">"
			.Write "  </span>"
			.Write " </form>"
		 End With
	 End Sub

End Class
%> 
