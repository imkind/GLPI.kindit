<%
'****************************************************
' Software name:Kesion CMS 7.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim LFCls:Set LFCls=New LabelBaseFunCls
Class LabelBaseFunCls
		Private KS     
		Private Sub Class_Initialize()
		  Set KS=New PublicCls
		End Sub
        Private Sub Class_Terminate()
		 Set KS=Nothing
		 Set LFCls=Nothing
		End Sub
				
		
		'前台向主数据表插入数据
		Sub InserItemInfo(ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,Inputer,Verific,Fname)
		 Call AddItemInfo(ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,now,Inputer,0,0,0,0,0,0,0,0,0,0,1,Verific,Fname)
		End Sub
		'前台向主数据表修改数据
		Sub ModifyItemInfo(ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,Verific)
		 Gcls.Execute("Update [KS_ItemInfo] Set Title='" & Title & "',Tid='" & Tid & "',Intro='" & Replace(left(KS.LoseHtml(Intro),255),"'","")  & "',KeyWords='" & Replace(KeyWords,"'","") & "',PhotoUrl='" & PhotoUrl & "',AddDate='" & Now & "',Verific=" & Verific & " Where  ChannelID=" & ChannelID & " and InfoID=" & InfoID)
		End Sub		
		
        '后台向系统主数据表添加数据
        Sub AddItemInfo(ByVal ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,AddDate,Inputer,Hits,HitsByDay,HitsByWeek,HitsByMonth,Recommend,Rolls,Strip,Popular,Slide,IsTop,Comment,Verific,Fname)
		 Gcls.Execute("Insert Into [KS_ItemInfo](ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,AddDate,Inputer,Hits,HitsByDay,HitsByWeek,HitsByMonth,Recommend,Rolls,Strip,Popular,Slide,IsTop,Comment,Verific,DelTF,Fname) values(" & Channelid & "," & InfoID & ",'" & Title & "','" & Tid & "' ,'" & left(Replace(KS.LoseHtml(Intro),"'",""),255) & "','" & Replace(KeyWords,"'","") & "' ,'" & PhotoUrl & "' ,'" & AddDate & "' ,'" & Inputer & "' ," & Hits & "," & HitsByDay & ", " & HitsByWeek & "," & HitsByMonth & "," & Recommend & "," & Rolls & "," & KS.ChkClng(Strip) & "," & Popular & "," & Slide & "," & IsTop & "," & Comment & "," & Verific& ",0,'" & Fname & "')")
		End Sub
		'后台修改数据表数据
		Sub UpdateItemInfo(ChannelID,InfoID,Title,Tid,Intro,KeyWords,PhotoUrl,AddDate,Hits,HitsByDay,HitsByWeek,HitsByMonth,Recommend,Rolls,Strip,Popular,Slide,IsTop,Comment,Verific)
		 Gcls.Execute("Update [KS_ItemInfo] Set Title='" & Title & "',Tid='" & Tid & "',Intro='" & Replace(left(KS.LoseHtml(Intro),255),"'","")  & "',KeyWords='" & Replace(KeyWords,"'","") & "',PhotoUrl='" & PhotoUrl & "',AddDate='" & AddDate & "',Hits=" & Hits & ",HitsByDay=" & HitsByDay & ",HitsByWeek=" & HitsByWeek & ",HitsByMonth=" & HitsByMonth & ",Recommend=" & Recommend & ",Rolls=" & Rolls & ",Strip=" & Strip & ",Popular=" & Popular & ",Slide=" & Slide & ",IsTop=" & IsTop  &",Comment=" & Comment & ",Verific=" & Verific & " Where  ChannelID=" & ChannelID & " and InfoID=" & InfoID)
		End Sub		
		'*********************************************************************************************************
		'函数名：GetAbsolutePath
		'作  用：返回数据库的绝对路径
		'参  数：RelativePath 数据库连接字段串
		'*********************************************************************************************************
		Function GetAbsolutePath(RelativePath)
			dim Exp_Path,Matches,tempStr
			tempStr=Replace(RelativePath,"\","/")
			if instr(tempStr,":/")>0 then
				GetAbsolutePath=RelativePath
				Exit Function
			End if
			set Exp_Path=new RegExp
			Exp_Path.Pattern="(Data Source=|dbq=)(.)*"
			Exp_Path.IgnoreCase=true
			Exp_Path.Global=true
			Set Matches=Exp_Path.Execute(tempStr)
			If instr(LCase(tempStr),"*.xls")<>0 Then
			GetAbsolutePath="driver={microsoft excel driver (*.xls)};dbq="&Server.MapPath(split(Matches(0).value,"=")(1))
			ElseIf Instr(Lcase(tempstr),"*.dbf")<>0 Then
			GetAbsolutePath="driver={microsoft dbase driver (*.dbf)};dbq="&Server.MapPath(split(Matches(0).value,"=")(1))
			Else
			GetAbsolutePath="Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&Server.MapPath(split(Matches(0).value,"=")(1))
			End If
		End Function

		'*********************************************************************************************************
		'函数名：ReplaceDBNull
		'作  用：替换数据库空值通用函数
		'参  数：DBField 字段值,DefaultValue 空间替换的值
		'*********************************************************************************************************
		Function ReplaceDBNull(DBField,DefaultValue)
		    If IsNull(DBField) Or (DBField="") then
			ReplaceDBNull=DefaultValue
			Else
			ReplaceDBNull = DBField
			end if
		End Function
		'*********************************************************************************************************
		'函数名：GetSingleFieldValue
		'作  用：取单字段值
		'参  数：SQLStr SQL语句
		'*********************************************************************************************************
		Function GetSingleFieldValue(SQLStr)
		    If DataBaseType=0 then
			On Error Resume Next
			GetSingleFieldValue=Conn.Execute(SQLStr)(0)
			If Err Then GetSingleFieldValue=""
			Else
			 Dim RS:Set RS=Conn.Execute(SQLStr)
			 If Not RS.Eof Then
			  GetSingleFieldValue=RS(0)
			 Else
			  GetSingleFieldValue=""
			 End If
			 RS.Close:Set RS=Nothing
			end if
		End Function
		
		'*********************************************************************************************************
		'函数名：GetConfigFromXML
		'作  用：取xml节点配置信息
		'参  数：FileName xml文件名(不含扩展名),Path 节点路径 ,NodeName 节点Name属性值
		'*********************************************************************************************************
		Function GetConfigFromXML(FileName,Path,NodeName)
		  If Not IsObject(Application(KS.SiteSN&"_Config"&FileName)) Then
			  Set Application(KS.SiteSN&"_Config"&FileName)=GetXMLFromFile(FileName)
		  End If
		  Dim Node:Set Node= Application(KS.SiteSN&"_Config"&FileName).documentElement.selectSingleNode(Path & "[@name='" & NodeName & "']")
		  If Not Node Is Nothing Then
		   GetConfigFromXML=Node.text
		  End If
		End Function
		'*********************************************************************************************************
		'函数名：GetXMLFromFile
		'作  用：取xml文件到Application
		'参  数：FileName xml文件名(不含扩展名)
		'*********************************************************************************************************
		Function GetXMLFromFile(FileName)
		 	If Not IsObject(Application(KS.SiteSN&"_Config"&FileName)) Then
			  Dim Doc:set Doc = KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
			  Doc.async = false
			  Doc.setProperty "ServerHTTPRequest", true 
			  Doc.load(Server.MapPath(KS.Setting(3)&"Config/" & FileName &".xml"))
			  Set Application(KS.SiteSN&"_Config"&FileName)=Doc
		   End If  
            Set GetXMLFromFile=Application(KS.SiteSN&"_Config"&FileName)
		End Function
		
		'*********************************************************************************************************
		'函数名：ReplacePrevNext
		'作  用：上一篇、下一篇
		'参  数：NowID 现在ID,Tid 目录ID,TypeStr类型
		'*********************************************************************************************************
		Function GetPrevNextURL(ChannelID,NowID, Tid, TypeStr,ByRef Title)
		     Dim SqlStr,LinkUrl
		     SqlStr="SELECT Top 1 ID,Title,Tid,Fname From " & KS.C_S(ChannelID,2) & " Where Tid='" & Tid & "' And ID" & TypeStr & NowID & " And Verific=1 and  DelTF=0 Order By ID"
			 If TypeStr=">" Then SqlStr=SqlStr & " asc" else SqlStr=SqlStr & " desc"
			 Dim RS:Set RS=Conn.Execute(SqlStr)
			 If RS.EOF And RS.BOF Then
			  GetPrevNextURL = "#" : Title = "没有了"
			 Else
			  LinkUrl = KS.GetItemURL(ChannelID,RS(2),RS(0),RS(3))
			  GetPrevNextURL = LinkUrl : Title= "<a href=""" & LinkUrl & """ title=""" & RS(1) & """>" & RS(1) & "</a>"
			 End If
			 RS.Close:Set RS = Nothing
		End Function
		Function ReplacePrevNext(ChannelID,NowID, Tid, TypeStr)
		     Dim Title
			 Call GetPrevNextURL(ChannelID,NowID, Tid, TypeStr,Title)
			 ReplacePrevNext=Title
		End Function
		
        '取文本字段的值
		'参数说明：字段值,截段字数,未尾输出的字符,HTML处理方式
		Function Get_Text_Field(FieldValue,CutNum,EndTag,HtmlTag,DefaultChar)
		 Dim TempStr:TempStr=FieldValue
		 If KS.IsNul(FieldValue) Then Get_Text_Field=DefaultChar : Exit Function
		 If Not IsNumeric(HtmlTag) Or Not IsNumeric(CutNum) Then Exit Function
		 If HtmlTag=0 Then
		  TempStr=KS.HtmlCode(TempStr)
		 ElseIf HtmlTag=1 Then
		  TempStr=TempStr
		 ElseIF HtmlTag=2 Then
		  TempStr=Replace(KS.LoseHtml(KS.HtmlCode(TempStr))," ","")
		 End If
          If EndTag="0" Then EndTag=""
		  if KS.strLength(TempStr)>cint(CutNum) and CutNum<>0 then TempStr = KS.GotTopic(TempStr, Cint(CutNum)) & EndTag
		 Get_Text_Field=TempStr
		End Function
		'取数字字段的值
		'参数说明：FieldValue-字段值,OutType-输出方式0、原数，1、小数，2百分数,XSWS-小数位数
		Function Get_Num_Field(FieldValue,OutType,XSWS)
		 If Not IsNumeric(FieldValue) Then Get_Num_Field=FieldValue:Exit Function
		 If Not IsNumeric(OutType) Then OutType=0
		 If Not IsNumeric(XSWS) Then XSWS=0
         If OutType=1 Then
		   Get_Num_Field=FormatNumber(FieldValue,XSWS)
		 ElseIf OutType=2 Then
		   Get_Num_Field=FormatPercent(FieldValue)
		 Else
		   Get_Num_Field=FieldValue
		 End if  
		End Function
		'取日期字段的值
		'参数说明：FieldValue-字段值,DateMB-输出日期模板
		Function Get_Date_Field(FieldValue,DateMB)
		  IF Not IsDate(FieldValue) Then Get_Date_Field=FieldValue:Exit Function
		  Get_Date_Field=Replace(DateMB,"YYYY",Year(FieldValue))
		  Get_Date_Field=Replace(Get_Date_Field,"YY",Right("0" & Year(FieldValue), 2))
		  Get_Date_Field=Replace(Get_Date_Field,"MM",Right("0" & Month(FieldValue), 2))
		  Get_Date_Field=Replace(Get_Date_Field,"DD",Right("0" & Day(FieldValue), 2))
		  Get_Date_Field=Replace(Get_Date_Field,"hh",Right("0" & hour(FieldValue), 2))
		  Get_Date_Field=Replace(Get_Date_Field,"mm",Right("0" & minute(FieldValue), 2))
		  Get_Date_Field=Replace(Get_Date_Field,"ss",Right("0" & second(FieldValue), 2))
		End Function		
		
		'替换自定义字段
		Function ReplaceUserDefine(ChannelID,F_C,ByVal RS)
		   If Not IsObject(Application(KS.SiteSN&"_userfiledlist"&channelid)) Then
		     Set  Application(KS.SiteSN&"_userfiledlist"&channelid)=KS.InitialObject("msxml2.FreeThreadedDOMDocument"& MsxmlVersion)
			 Application(KS.SiteSN&"_userfiledlist"&channelid).appendChild(Application(KS.SiteSN&"_userfiledlist"&channelid).createElement("xml"))
				Dim D_F_Arr,K,Node,FieldName
				Dim KS_RS_Obj:Set KS_RS_Obj=Conn.Execute("Select FieldName From KS_Field Where ChannelID=" & ChannelID &" And ShowOnForm=1 Order By OrderID Asc")
				If Not KS_RS_Obj.Eof Then D_F_Arr=KS_RS_Obj.GetRows(-1)
			    KS_RS_Obj.Close:Set KS_RS_Obj=Nothing
				If IsArray(D_F_Arr) Then
					  For K=0 To Ubound(D_F_Arr,2)
						Set Node=Application(KS.SiteSN&"_userfiledlist"&channelid).documentElement.appendChild(Application(KS.SiteSN&"_userfiledlist"&channelid).createNode(1,"userfiledlist"&channelid,""))
						Node.attributes.setNamedItem(Application(KS.SiteSN&"_userfiledlist"&channelid).createNode(2,"fieldname","")).text=D_F_Arr(0,K)
					 Next
				 End If
		 End If
		 
		 For Each Node in Application(KS.SiteSN&"_userfiledlist"&channelid).documentElement.SelectNodes("userfiledlist"&channelid)
		     FieldName=Node.selectSingleNode("@fieldname").text
			If Not IsNull(RS(FieldName)) Then
			  F_C=Replace(F_C,"{$" & FieldName & "}",RS(FieldName))
			Else
			  F_C=Replace(F_C,"{$" & FieldName & "}","")
			End If
		 Next
		ReplaceUserDefine=F_C
	End Function
End Class
%> 
