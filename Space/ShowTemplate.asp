<%@LANGUAGE="VBSCRIPT" CODEPAGE="936"%>
<%option explicit%>
<!--#include file="../Conn.asp"-->
<!--#include file="../KS_Cls/Kesion.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.Label.CommonCls.asp"-->
<!--#include file="../KS_Cls/Kesion.SpaceApp.asp"-->
<%
'****************************************************
' Software name:Kesion CMS 7.0
' Email: service@kesion.com . QQ:111394,9537636
' Web: http://www.kesion.com http://www.kesion.cn
' Copyright (C) Kesion Network All Rights Reserved.
'****************************************************
Dim KS,KSBCls,KSR
Set KS=New PublicCls
Set KSBCls=New BlogCls
dim TemplateID,Tp
TemplateID=KS.ChkClng(KS.S("TemplateID"))
Tp=KSBCls.GetTemplatePath(TemplateID,"TemplateMain")
Tp=Replace(tp,"{$GetInstallDir}",KS.Setting(3))
Tp=Replace(tp,"{$GetSiteUrl}",KS.Setting(2))
KS.Echo Tp
Set KS=Nothing
Set KSBCls=Nothing
call closeconn()
%>