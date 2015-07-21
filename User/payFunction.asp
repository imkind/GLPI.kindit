﻿<%
Dim SUserName,SUserCardID,sPayFrom,sAction  '主要用于保存paypal返回的数据

'更新订单记录
Sub UpdateOrder(v_amount,remark2,v_oid,v_pmode)
 Dim KSUser:Set KSUser=New UserCls
 Dim UserName,MoneyType,Money,Remark,sqlUser,rsUser,orderid,mobile,Action
 orderid=v_oid
 IF Cbool(KSUser.UserLoginChecked) Then UserName=KSUser.UserName Else UserName=KS.S("UserName")
         
		 '=======================如果从request里得不到数据，则重新取值=================
		 If UserName="" Then UserName=SUserName
		 Dim UserCardID
		 UserCardID=KS.ChkClng(KS.S("UserCardID"))
		 iF UserCardID=0 Then UserCardID=sUserCardID
		 Action=KS.G("Action"): If Action="" Then Action=Saction
		 '==============================================================================
		 
         Mobile=KSUser.GetUserInfo("Mobile")
		 Money=v_amount
		 Remark=remark2
		 Dim RSLog,RS
		Set RSLog=Server.CreateObject("ADODB.RECORDSET")
		RSLog.Open "Select top 1 * From KS_LogMoney where orderid='" & v_oid & "'",Conn,1,1
		if RSLog.Eof And RSLog.BoF Then
			 Select Case Action
			 case "shop"   '商城中心购物
				 Set RS=Server.CreateObject("ADODB.RECORDSET")
				 RS.Open "Select top 1 * From KS_Order Where OrderID='" & v_oid & "'",Conn,1,3
				 If RS.Eof Then
				   RS.Close:Set RS=Nothing
				   KS.Die "<br><li>支付过程中遇到问题，请联系网站管理员！"
				 End If
				  If Mobile="" Then
				  Mobile=RS("Mobile")
				  End If
				  RS("MoneyReceipt")=Money
				  Dim OrderStatus:OrderStatus=rs("status")
				  RS("Status")=1
				  RS("PayTime")=now   '记录付款时间
				  RS.Update
                  orderid=RS("OrderID")
				  Call KS.MoneyInOrOut(rs("UserName"),RS("Contactman"),Money,2,1,now,rs("orderid"),"System","为购买订单：" &v_oid & "使用" & v_pmode & "在线充值",0,0,0)
		          Call KS.MoneyInOrOut(rs("UserName"),RS("Contactman"),Money,4,2,now,rs("orderid"),"System",Remark,0,0,0)
				  
					
					'====================为用户增加购物应得积分========================
					Dim rsp:set rsp=conn.execute("select point,id,title from ks_product where id in(select proid from KS_OrderItem where orderid='" & rs("orderid") & "')")
					do while not rsp.eof
					  dim amount:amount=conn.execute("select top 1 amount from ks_orderitem where orderid='" & rs("orderid") & "' and proid=" & rsp(1))(0)
					  If OrderStatus<>1 Then
					  conn.execute("update ks_product set totalnum=totalnum-" & amount &" where totalnum>=" & amount &" and id=" & rsp(1))
					 ' response.write rs("orderid") & "=55<br>"
					 ' response.write amount & "<br>"
					 ' response.write username & "<br>"
					  
					  Call KS.ScoreInOrOut(UserName,1,KS.ChkClng(rsp(0))*amount,"系统","购买商品<font color=red>" & rsp("title") & "</font>赠送!",0,0)
					  End if
					  
					rsp.movenext
					loop
					rsp.close
					set rsp=nothing
					'================================================================
					
					RS.Close:Set RS=Nothing
			 Case else   '会员中心充值
					Set rsUser=Server.CreateObject("Adodb.RecordSet")
					sqlUser="select top 1 * from KS_User where UserName='" & UserName & "'"
					rsUser.Open sqlUser,Conn,1,1
					if rsUser.bof and rsUser.eof then
								Response.Write "<br><li>充值过程中遇到问题，请联系网站管理员！"
								rsUser.close:set rsUser=Nothing
								exit sub
					end if
					Dim RealName:RealName=rsUser("RealName")
					Dim Edays:Edays=rsUser("Edays")
					Dim BeginDate:BeginDate=rsUser("BeginDate")
					rsUser.Close : Set rsUser=Nothing

					If UserCardID<>0 Then   '充值卡
					       Call UpdateByCard(0,UserCardID,UserName,RealName,Edays,BeginDate,v_oid,v_pmode)
					Else
				  	 Call KS.MoneyInOrOut(UserName,RealName,Money,3,1,now,v_oid,"System",v_pmode & "在线充值,订单号为:" & v_oid,0,0,0)
					End If

					
			 End Select
			 
		End If
		RSLog.Close:Set RSLog=Nothing
End Sub

'根据充值卡更新用户
Sub UpdateByCard(CallFrom,UserCardID,UserName,RealName,Edays,BeginDate,v_oid,v_pmode)
  Dim Str,KS:Set KS=New PublicCls
  If CallFrom=1 Then Str="通过" Else Str="在线购买"
  Conn.Execute("Update KS_User Set UserCardID=" & UserCardID & " where username='" & userName & "'")
   Dim RSCard:Set RSCard=conn.execute("select top 1 * From KS_UserCard Where ID="&UserCardID)
  If Not RSCard.Eof Then
		Dim ValidNum:ValidNum=RSCard("ValidNum")
		Dim CardTitle:CardTitle=RSCard("GroupName")
		If RSCard("groupid")<>0 Then
		  Conn.Execute("Update KS_User Set GroupID=" & KS.ChkClng(RSCard("GroupID")) & ",ChargeType=" & KS.ChkClng(KS.U_G(RSCard("groupid"),"chargetype")) &" where username='" & userName & "'") 
		End If
							    
		Select Case RSCard("ValidUnit")
			 case 1
				Call KS.PointInOrOut(0,0,UserName,1,ValidNum,"System",str & "充值卡[" & CardTitle &"]获得的点数",0)
			 case 2
				Dim tmpDays:tmpDays=Edays-DateDiff("D",BeginDate,now())
				  if tmpDays>0 then
						 Conn.Execute("Update KS_User Set Edays=Edays+" & ValidNum & " where username='" & userName & "'") 
				  else
					     Conn.Execute("Update KS_User Set Edays=" & ValidNum & ",BeginDate=" & SQLNowString& " where username='" & userName & "'") 
				 end if
				Call KS.EdaysInOrOut(UserName,1,ValidNum,"System",str & "充值卡[" & CardTitle &"]获得的有效天数")
                                       
			case 3
				Call KS.MoneyInOrOut(UserName,RealName,ValidNum,3,1,now,v_oid,"System",v_pmode & "在线充值,在线购买充值卡[" & CardTitle &"]获得的资金",0,0,0)
			case 4
				Call KS.ScoreInOrOut(UserName,1,ValidNum,"System",str & "充值卡[" & CardTitle & "]获得的积分!",0,0)
		 End Select
        If RSCard("ValidUnit")<>3 Then
		   If CallFrom=1 Then
			Call KS.MoneyInOrOut(UserName,RealName,RSCard("Money"),3,2,now,v_oid,"System", "用于购买充值卡[" & CardTitle &"]!",0,0,0)
		   Else
			Call KS.MoneyInOrOut(UserName,RealName,RSCard("Money"),3,1,now,v_oid,"System",v_pmode & "在线充值!",0,0,0)
			Call KS.MoneyInOrOut(UserName,RealName,RSCard("Money"),3,2,now,v_oid,"System", "为购买充值卡[" & CardTitle &"]而支出!",0,0,0)
		   End If
		 End If
	 End If 
	RSCard.Close:Set RSCard=Nothing
	Set KS=Nothing
End Sub

Sub GetPayMentField(OrderID,PaymentPlat,Money,UserCardID,ProductName,PayFrom,KSUser,ByRef PayMentField,ByRef PayUrl,ByRef ReturnUrl,ByRef Title,ByRef RealPayMoney,ByRef RealPayUSDMoney,ByRef RateByUser,ByRef PayOnlineRate)
    Dim KS:Set KS=New PublicCls
		If UserCardID<>0 Then
		   Dim RS:Set RS=Conn.Execute("Select Top 1 Money,GroupName From KS_UserCard Where ID=" & UserCardID)
		   If Not RS.Eof Then
		    Title=RS(1)
		    Money=RS(0)
			RS.Close : Set RS=Nothing
		   Else
		    RS.Close : Set RS=Nothing
		    Call KS.AlertHistory("出错啦！",-1)
			Exit Sub
		   End If
		ElseIf ProductName<>"" Then
		   Title="购买:"+KS.CheckXss(ProductName)
		Else
		   Title="为自己的账户充值"
		End If
		
		
		If Not IsNumeric(Money) Then
		  Call KS.AlertHistory("对不起，您输入的充值金额不正确！",-1)
		  exit sub
		End If

		
		If Money=0 Then
		  Call KS.AlertHistory("对不起，充值金额最低为0.01元！",-1)
		  exit sub
		End If
		
		Dim RSP:Set RSP=Server.CreateObject("ADODB.RECORDSET")
		RSP.Open "Select top 1 * From KS_PaymentPlat where id=" & PaymentPlat,conn,1,1
		If RSP.Eof Then
		 RSP.Close:Set RSP=Nothing
		 Response.Write "Error!"
		 Response.End()
		End If
		Dim AccountID:AccountID=RSP("AccountID")
		Dim MD5Key:MD5Key=RSP("MD5Key")
		PayOnlineRate=RSP("Rate") 
		RateByUser=KS.ChkClng(RSP("RateByUser")) 
		RSP.Close:Set RSP=Nothing
		
		RealPayMoney=Money
		If RateByUser=1 Then
		  RealPayMoney=RealPayMoney+RealPayMoney*PayOnlineRate/100
		End If
		RealPayMoney=round(RealPayMoney,2)
		
		If PaymentPlat=12 Then  'paypal支付
		   If Not IsNumeric(KS.Setting(81)) Then
		     KS.AlertHintScript "美元汇率不正确，请到基本信息设置->商城选项里设置"
			 KS.Die ""
		   End If
		   RealPayUSDMoney=round(RealPayMoney / KS.Setting(81),2) '折算应付的美金
		 End If
		
		Dim v_amount,v_moneytype,v_md5info,v_oid,v_mid,v_url,remark1,remark2
		ReturnUrl=KS.GetDomain & "user/User_PayReceive.asp?PaymentPlat=" & PaymentPlat &"&username=" & server.URLEncode(KSUser.userName) & "&action=" &PayFrom&"&usercardid=" & UserCardID   ' 商户自定义返回接收支付结果的页面 Receive.asp 为接收页面
		remark1 = KSUser.UserName			            ' 备注字段1
		remark2 = "在线充值，订单号为:" &OrderID		' 备注字段2
		
		v_oid = OrderID
		v_amount=RealPayMoney
		v_moneytype="0"
		v_mid = AccountID
		v_url = ReturnUrl
		
		Dim v_ymd, v_hms
		v_ymd = Year(Date) & Right("0" & Month(Date), 2) & Right("0" & Day(Date), 2)
		v_hms = Right("0" & Hour(Time), 2) & Right("0" & Minute(Time), 2) & Right("0" & Second(Time), 2)
		Select Case PaymentPlat
		 case 12,13  'PayPal
		   'PayUrl = "https://www.sandbox.paypal.com/cgi-bin/webscr"   '测试接口,实际应用应用以下接口
		   PayUrl = "https://www.paypal.com/cgi-bin/webscr"           '实际接口。
		   PayMentField = PayMentField & "<input type=""hidden"" name=""add"" value=""1"">" &vbcrlf
		   PayMentField = PayMentField & "<input type=""hidden"" name=""cmd"" value=""_xclick"">" &vbcrlf
		   PayMentField = PayMentField & "<input type=""hidden"" name=""business"" value=""" & AccountID &""">" &vbcrlf
		   PayMentField = PayMentField & "<input type=""hidden"" name=""item_name"" value=""" & title  &""">" &vbcrlf
		   PayMentField = PayMentField & "<input type=""hidden"" name=""item_number"" value=""" & v_oid  &""">" &vbcrlf
		   If PaymentPlat=13 Then 'PayPal 贝宝
			   PayMentField = PayMentField & "<input type=""hidden"" name=""amount"" value=""" & RealPayMoney & """>" &vbcrlf
			   PayMentField = PayMentField & "<input type=""hidden"" name=""currency_code"" value=""CNY"">"&vbcrlf
		   Else
			   PayMentField = PayMentField & "<input type=""hidden"" name=""amount"" value=""" & RealPayUSDMoney & """>" &vbcrlf
			   PayMentField = PayMentField & "<input type=""hidden"" name=""currency_code"" value=""USD"">"&vbcrlf
		   End If
		   PayMentField = PayMentField & "<input type=""hidden"" name=""return"" value=""" & ReturnUrl & """>"&vbcrlf
           PayMentField = PayMentField & "<input type='hidden' name='charset' value='utf-8'>"    'utf编码
           PayMentField = PayMentField & "<input type='hidden' name='custom' value='" & KS.C("UserName") & "|" & PayFrom & "|" & UserCardID &"'>"    '传自己的参数
		
		 Case 1 '网银在线
		  PayUrl="https://pay3.chinabank.com.cn/PayGate"
		  v_md5info=Ucase(trim(md5(v_amount&v_moneytype&v_oid&v_mid&v_url&MD5Key,32)))	'网银支付平台对MD5值只认大写字符串
	
		  PayMentField="<input type=""hidden"" name=""v_md5info"" value=""" & v_md5info &""">" & _
	                   "<input type=""hidden"" name=""v_mid""  value=""" & v_mid & """>" & _
	                   "<input type=""hidden"" name=""v_oid""  value=""" & v_oid & """>" & _
                  	   "<input type=""hidden"" name=""v_amount"" value=""" & v_amount & """>" & _
	                   "<input type=""hidden"" name=""v_moneytype"" value=""" & v_moneytype & """>" & _
                       "<input type=""hidden"" name=""v_url""  value=""" & v_url & """>" & _
                       "<!--以下几项项为网上支付完成后，随支付反馈信息一同传给信息接收页，在传输过程中内容不会改变,如：Receive.asp -->" & _
                        "<input type=""hidden""  name=""remark2"" value=""" & remark2 & """>"

		 Case 2  '中国在线支付网
			PayUrl = "http://www.ipay.cn/4.0/bank.shtml"
			v_oid = cstr(Hour(Now) & Second(Now) & Minute(Now))	
			v_md5info = LCase(MD5(v_mid & v_oid & v_amount & KSUser.GetUserInfo("Email") & KSUser.GetUserInfo("Mobile") & MD5Key, 32))
			PayMentField = PayMentField & "<input type='hidden' name='v_mid' value='" & v_mid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_oid' value='" & v_oid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_amount' value='" & v_amount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_email' value='" & KSUser.GetUserInfo("Email") & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_mobile' value='" & KSUser.GetUserInfo("Mobile") & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_md5'    value='" & v_md5info & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='v_url' value='" & v_url & "'>" & vbCrLf
		 Case 3  '上海环迅
		    PayUrl = "https://www.ips.com.cn/ipay/ipayment.asp"
			v_mid = Right("000000" & v_mid, 6)
			PayMentField = PayMentField & "<input type='hidden' name='mer_code' value='" & v_mid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='billNo' value='" & v_mid & v_hms & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='amount' value='" & v_amount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='date' value='" & v_ymd & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='lang'  value='1'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='currency'   value='01'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Merchanturl'   value='" & v_url & "'>" & vbCrLf
	     Case 4  '西部支付
			PayUrl = "http://www.yeepay.com/Pay/WestPayReceiveOrderFromMerchant.asp"
			PayMentField = PayMentField & "<input type='hidden' name='MerchantID' value='" & v_mid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='OrderNumber' value='" & v_oid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='OrderAmount' value='" & v_amount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='PostBackURL' value='" & v_url & "'>" & vbCrLf
		 Case 5  '易付通
			PayUrl = "http://pay.xpay.cn/Pay.aspx"
			v_md5info = LCase(MD5(MD5Key & ":" & v_amount & "," & v_oid & "," & v_mid & ",bank,,sell,,2.0", 32))
			PayMentField = PayMentField & "<input type='hidden' name='Tid' value='" & v_mid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Bid' value='" & v_oid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Prc' value='" & v_amount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='url' value='" & v_url & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Card' value='bank'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Scard' value=''>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='ActionCode' value='sell'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='ActionParameter' value=''>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Ver' value='2.0'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='Pdt' value='" & trim(KS.Setting(0)) & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='type' value=''>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='lang' value='utf-8'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='md' value='" & v_md5info & "'>" & vbCrLf
		Case 6   '云网支付
			PayUrl = "https://www.cncard.net/purchase/getorder.asp"
			v_url=split(v_url,"?")(0)
			v_md5info = LCase(MD5(v_mid & v_oid & v_amount & v_ymd & "01" & v_url & "6|" & KSUser.UserName & "|" &PayFrom&"|" & UserCardID & "00" & MD5Key, 32))
			PayMentField = PayMentField & "<input type='hidden' name='c_mid' value='" & v_mid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_order' value='" & v_oid & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_orderamount' value='" & v_amount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_ymd' value='" & v_ymd & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_moneytype' value='0'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_retflag' value='1'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_paygate' value=''>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_returl' value='" & v_url & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_memo1' value='6|" & KSUser.UserName & "|" &PayFrom&"|" & UserCardID & "'>" & vbCrLf  '传递商户ID号等
			PayMentField = PayMentField & "<input type='hidden' name='c_memo2' value=''>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_language' value='0'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='notifytype' value='0'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='c_signstr' value='" & v_md5info & "'>" & vbCrLf
		 Case 7,9  '支付宝
		    PayUrl="https://www.alipay.com/cooperate/gateway.do?_input_charset=gb2312"
			Dim Partner
			Dim ArrMD5Key
			If InStr(MD5Key, "|") > 0 Then
				ArrMD5Key = Split(MD5Key, "|")
				If UBound(ArrMD5Key) = 1 Then
					Partner = ArrMD5Key(1)
					MD5Key = ArrMD5Key(0)
				End If
			End If
			
			Session("PayType")="ALIPAY"
			If PaymentPlat=7 Then
			    v_url=KS.GetDomain & "user/Alipay_NotifyUrl.asp?username=" & ksuser.username &"&action=" &PayFrom&"&usercardid=" & UserCardID
				Dim myString:myString = "_input_charset=gb2312&discount=0" & "&notify_url=" & v_url & "&out_trade_no=" & v_oid & "&partner=" & Partner & "&payment_type=1" & "&price=" & v_amount & "&quantity=1" & "&return_url=" & returnurl & "&seller_email=" & v_mid & "&service=create_direct_pay_by_user&subject=" & Title & MD5Key
				input_charset="gb2312"
				v_md5info = LCase(MD5(myString, 32))
				'PayMentField = PayMentField & "<input type='hidden' name='_input_charset' value='utf-8'>" '商品折扣
				PayMentField = PayMentField & "<input type='hidden' name='discount' value='0'>" '商品折扣
				PayMentField = PayMentField & "<input type='hidden' name='notify_url' value='" & v_url & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='out_trade_no' value='" & v_oid & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='payment_type' value='1'>"
				PayMentField = PayMentField & "<input type='hidden' name='partner' value='" & Partner & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='price' value='" & v_amount & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='quantity' value='1'>"
				PayMentField = PayMentField & "<input type='hidden' name='seller_email' value='" & v_mid & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='service' value='create_direct_pay_by_user'>"
				PayMentField = PayMentField & "<input type='hidden' name='subject' value='" & Title & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='sign' value='" & v_md5info & "'>"
				PayMentField = PayMentField & "<input type='hidden' name='sign_type' value='MD5'>"
				PayMentField = PayMentField & "<input type='hidden' name='return_url' value='" & returnurl & "'>"
		  Else
		        'returnurl=""
				'v_url=""
				
				Dim body
				Dim IsFabrication
				If PayFrom="shop" Then
				 IsFabrication = False
				 Body="支付商品订单""" & V_oid & """的费用"
				Else
				 IsFabrication = True '资金充值,当做虚拟物品
				 Body="""" & KS.Setting(0) & """账户在线充值,订单号:" & v_oid
				End If
               ' If IsFabrication Then
               '     myString = LCase(MD5("notify_url=" & v_url & "&out_trade_no=" & v_oid & "&partner=" & Partner & "&price=" & v_amount & "&quantity=1" & "&return_url=" & returnurl & "&seller_email=" & v_mid & "&service=create_digital_goods_trade_p&subject=" & v_oid & MD5Key, 32))
              '  Else
                    myString = LCase(MD5("body=" & body & "&discount=0&logistics_fee=0&logistics_payment=BUYER_PAY&logistics_type=EXPRESS&out_trade_no=" & v_oid & "&partner=" & Partner & "&payment_type=1&price=" & v_amount & "&quantity=1&seller_email=" & v_mid & "&service=create_partner_trade_by_buyer&subject=" & v_oid & MD5Key, 32))
               ' End If
                 
				PayMentField = PayMentField & "<input type='hidden' name='body' value='" & body & "'>" & vbCrLf
				PayMentField = PayMentField & "<input type='hidden' name='discount' value='0'>" & vbCrLf
				PayMentField = PayMentField & "<input type='hidden' name='logistics_fee' value='0'>" & vbCrLf

				               
               ' If IsFabrication Then
              '      PayMentField = PayMentField & "<input type='hidden' name='service' value='create_digital_goods_trade_p'>" & vbCrLf
               ' Else
                    PayMentField = PayMentField & "<input type='hidden' name='logistics_payment' value='BUYER_PAY'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='logistics_type' value='EXPRESS'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='out_trade_no' value='" & v_oid & "'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='partner' value='" & Partner & "'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='payment_type' value='1'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='price' value='" & v_amount & "'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='quantity' value='1'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='seller_email' value='" & v_mid & "'>" & vbCrLf
					PayMentField = PayMentField & "<input type='hidden' name='service' value='create_partner_trade_by_buyer'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='subject' value='" & v_oid & "'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='sign' value='" & myString & "'>" & vbCrLf
                    PayMentField = PayMentField & "<input type='hidden' name='sign_type' value='MD5'>" & vbCrLf
					
					
					
                    'PayMentField = PayMentField & "<input type='hidden' name='logistics_fee' value='0'>" & vbCrLf
               ' End If
                'PayMentField = PayMentField & "<input type='hidden' name='notify_url' value='" & v_url & "'>" & vbCrLf
                'PayMentField = PayMentField & "<input type='hidden' name='return_url' value='" & returnurl & "'>"

		  End If
			
		 Case 8  '快钱支付
			PayUrl = "https://www.99bill.com/gateway/recvMerchantInfoAction.htm"
			Dim OrderAmount,merchantAcctId, key, inputCharset, pageUrl, bgUrl, version, language, signType, payerName, payerContactType, payerContact
			Dim orderTime, productNum, productId, productDesc, ext1, ext2, payType, bankId, redoFlag, pid, signMsgVal
			merchantAcctId = v_mid   '网关账户号
			key = MD5Key '网关密钥
			inputCharset = "3" '1代表UTF-8; 2代表GBK; 3代表utf-8
			pageUrl = v_url '接受支付结果的页面地址
			bgUrl = v_url '服务器接受支付结果的后台地址
			version = "v2.0" '网关版本.固定值
			language = "1" '1代表中文；2代表英文
			signType = "1" '1代表MD5签名
			payerName = "" '支付人姓名
			payerContactType = "" '支付人联系方式类型 1代表Email；2代表手机号
			payerContact = "" '支付人联系方式,只能选择Email或手机号
			orderId = v_oid '商户订单号
			OrderAmount = v_amount * 100 '订单金额,以分为单位
			orderTime = v_ymd & v_hms '订单提交时间,14位数字
			'productName = "" '商品名称
			productNum = "" '商品数量
			productId = "" '商品代码
			productDesc = "" '商品描述
			ext1 = "" '扩展字段1,在支付结束后原样返回给商户
			ext2 = "" '扩展字段2
			payType = "00" '支付方式,00：组合支付,显示快钱支持的各种支付方式,11：电话银行支付,12：快钱账户支付,13：线下支付,14：B2B支付
			bankId = "" '银行代码,实现直接跳转到银行页面去支付,具体代码参见 接口文档银行代码列表,只在payType=10时才需设置参数
			redoFlag = "1" '同一订单禁止重复提交标志:1代表同一订单号只允许提交1次,0表示同一订单号在没有支付成功的前提下可重复提交多次
			pid = "" '快钱的合作伙伴的账户号
	
			signMsgVal = appendParam(signMsgVal, "inputCharset", inputCharset)
			signMsgVal = appendParam(signMsgVal, "pageUrl", pageUrl)
			signMsgVal = appendParam(signMsgVal, "bgUrl", bgUrl)
			signMsgVal = appendParam(signMsgVal, "version", version)
			signMsgVal = appendParam(signMsgVal, "language", language)
			signMsgVal = appendParam(signMsgVal, "signType", signType)
			signMsgVal = appendParam(signMsgVal, "merchantAcctId", merchantAcctId)
			signMsgVal = appendParam(signMsgVal, "payerName", payerName)
			signMsgVal = appendParam(signMsgVal, "payerContactType", payerContactType)
			signMsgVal = appendParam(signMsgVal, "payerContact", payerContact)
			signMsgVal = appendParam(signMsgVal, "orderId", v_oid)
			signMsgVal = appendParam(signMsgVal, "orderAmount", OrderAmount)
			signMsgVal = appendParam(signMsgVal, "orderTime", orderTime)
			signMsgVal = appendParam(signMsgVal, "productName", productName)
			signMsgVal = appendParam(signMsgVal, "productNum", productNum)
			signMsgVal = appendParam(signMsgVal, "productId", productId)
			signMsgVal = appendParam(signMsgVal, "productDesc", productDesc)
			signMsgVal = appendParam(signMsgVal, "ext1", ext1)
			signMsgVal = appendParam(signMsgVal, "ext2", ext2)
			signMsgVal = appendParam(signMsgVal, "payType", payType)
			signMsgVal = appendParam(signMsgVal, "bankId", bankId)
			signMsgVal = appendParam(signMsgVal, "redoFlag", redoFlag)
			signMsgVal = appendParam(signMsgVal, "pid", pid)
			signMsgVal = appendParam(signMsgVal, "key", key)
			v_md5info = UCase(MD5(signMsgVal, 32))
			PayMentField = PayMentField & "<input type='hidden' name='inputCharset' value='" & inputCharset & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='bgUrl' value='" & bgUrl & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='pageUrl' value='" & pageUrl & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='version' value='" & version & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='language' value='" & language & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='signType' value='" & signType & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='signMsg' value='" & v_md5info & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='merchantAcctId' value='" & merchantAcctId & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='payerName' value='" & payerName & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='payerContactType' value='" & payerContactType & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='payerContact' value='" & payerContact & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='orderId' value='" & orderId & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='orderAmount' value='" & OrderAmount & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='orderTime' value='" & orderTime & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='productName' value='" & productName & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='productNum' value='" & productNum & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='productId' value='" & productId & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='productDesc' value='" & productDesc & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='ext1' value='" & ext1 & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='ext2' value='" & ext2 & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='payType' value='" & payType & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='bankId' value='" & bankId & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='redoFlag' value='" & redoFlag & "'>" & vbCrLf
			PayMentField = PayMentField & "<input type='hidden' name='pid' value='" & pid & "'>" & vbCrLf
		Case 10 '财付通
		    Dim transaction_id,desc
		    If Title<>"" Then desc="订单号:" & v_oid & "<br/>" & Title Else Desc=KS.Setting(0) &title & "在线支付号:" & v_oid
			transaction_id = v_mid & v_ymd & Right(v_oid, 10)
			PayUrl = "https://www.tenpay.com/cgi-bin/v1.0/pay_gate.cgi"
			Dim spbill_create_ip:spbill_create_ip= Request.ServerVariables("REMOTE_ADDR")
			v_md5info = UCase(MD5("cmdno=1&date=" & v_ymd & "&bargainor_id=" & v_mid & "&transaction_id=" & transaction_id & "&sp_billno=" & v_oid & "&total_fee=" & v_amount * 100 & "&fee_type=1&return_url=" & v_url & "&attach=my_magic_string&spbill_create_ip=" &spbill_create_ip & "&key=" & MD5Key, 32))

			PayMentField = PayMentField & "<input type='hidden' name='cs' value='utf-8'>"    '传参编码
			PayMentField = PayMentField & "<input type='hidden' name='cmdno' value='1'>"   '业务代码,1表示支付
			PayMentField = PayMentField & "<input type='hidden' name='date' value='" & v_ymd & "'>"   '商户日期
			PayMentField = PayMentField & "<input type='hidden' name='bank_type' value='0'>"  '银行类型:财付通,0
			PayMentField = PayMentField & "<input type='hidden' name='desc' value='" & Desc & "'>"    '交易的商品名称
			PayMentField = PayMentField & "<input type='hidden' name='purchaser_id' value=''>"   '用户(买方)的财付通帐户,可以为空
			PayMentField = PayMentField & "<input type='hidden' name='bargainor_id' value='" & v_mid & "'>"  '商家的商户号
			PayMentField = PayMentField & "<input type='hidden' name='transaction_id' value='" & transaction_id & "'>"   '交易号(订单号)
			PayMentField = PayMentField & "<input type='hidden' name='sp_billno' value='" & v_oid & "'>"  '商户系统内部的定单号
			PayMentField = PayMentField & "<input type='hidden' name='total_fee' value='" & v_amount * 100 & "'>" '总金额，以分为单位
			PayMentField = PayMentField & "<input type='hidden' name='fee_type' value='1'>"  '现金支付币种,1人民币
			PayMentField = PayMentField & "<input type='hidden' name='return_url' value='" & v_url & "'>" '接收财付通返回结果的URL
			PayMentField = PayMentField & "<input type='hidden' name='attach' value='my_magic_string'>" '商家数据包，原样返回
			PayMentField = PayMentField & "<input type='hidden' name='sign' value='" & v_md5info & "'>" 'MD5签名
			PayMentField = PayMentField & "<input type='hidden' name='spbill_create_ip' value='"& spbill_create_ip &"'>"  
		case 11 '财付通中介交易
		    Dim mch_desc:mch_desc="在线购买订单号:" &v_oid
			Dim mch_name
			If ProductName<>"" Then 
			 mch_name=ProductName
		    Else
			 mch_name="在线购买订单号:" &v_oid
			End If
			Dim mch_price:mch_price=v_amount * 100
			Dim mch_returl:mch_returl=ReturnUrl
			Dim mch_type:mch_type=1
			Dim show_url:show_url=ReturnUrl
			Dim transport_desc:transport_desc=Request("DeliverName")
			
			PayUrl = "http://www.tenpay.com/cgi-bin/med/show_opentrans.cgi"
			dim buffer
					buffer = appendParam(buffer, "attach", 		"tencent_magichu")
					buffer = appendParam(buffer, "chnid", 			"1202640601")
					buffer = appendParam(buffer, "cmdno", 			"12")
					buffer = appendParam(buffer, "encode_type", 	"1")
					buffer = appendParam(buffer, "mch_desc", 		mch_desc)
					buffer = appendParam(buffer, "mch_name", 		mch_name)
					buffer = appendParam(buffer, "mch_price", 		mch_price)
					buffer = appendParam(buffer, "mch_returl", 	mch_returl)
					buffer = appendParam(buffer, "mch_type", 		mch_type)
					buffer = appendParam(buffer, "mch_vno", 		v_oid)
					buffer = appendParam(buffer, "need_buyerinfo", "2")
					buffer = appendParam(buffer, "seller", 		v_mid)
					buffer = appendParam(buffer, "show_url", 		show_url)
					buffer = appendParam(buffer, "transport_desc", transport_desc)
					buffer = appendParam(buffer, "transport_fee", 	0)
					buffer = appendParam(buffer, "version", 		2)
					
			        buffer = appendParam(buffer, "key", 			MD5Key)
					
			v_md5info=MD5(buffer,32)
					
			PayMentField = PayMentField & "<input type='hidden' name='attach' value='tencent_magichu'>" '商家数据包，原样返回
			PayMentField = PayMentField & "<input type='hidden' name='chnid' value='1202640601'>" '平台提供者的财付通账号
			PayMentField = PayMentField & "<input type='hidden' name='cmdno' value='12'>"   '业务代码,1表示支付
			PayMentField = PayMentField & "<input type='hidden' name='encode_type' value='1'>"   '编码
			PayMentField = PayMentField & "<input type='hidden' name='mch_desc' value='" & mch_desc&"'>"   '交易说明
			PayMentField = PayMentField & "<input type='hidden' name='mch_name' value='" & mch_name&"'>"   '商品名称
			PayMentField = PayMentField & "<input type='hidden' name='mch_price' value='"&mch_price&"'>"   '商品价格
			PayMentField = PayMentField & "<input type='hidden' name='mch_returl' value='"&mch_returl&"'>"   '回调通知URL,如果cmdno为12且此字段填写有效回调链接,财付通将把交易相关信息通知给此URL 
			PayMentField = PayMentField & "<input type='hidden' name='mch_type' value='"&mch_type&"'>"   '交易类型：1、实物交易，2、虚拟交易
			PayMentField = PayMentField & "<input type='hidden' name='mch_vno' value='"&v_oid&"'>"   '订单号
			PayMentField = PayMentField & "<input type='hidden' name='need_buyerinfo' value='2'>"   '是否需要在财付通填定物流信息，1：需要，2：不需要。
			PayMentField = PayMentField & "<input type='hidden' name='seller' value='" & v_mid & "'>"   '收款方财付通账号
			PayMentField = PayMentField & "<input type='hidden' name='show_url' value='"&show_url&"'>"   '支付后的商户支付结果展示页面
			PayMentField = PayMentField & "<input type='hidden' name='transport_desc' value='"&transport_desc&"'>"   '物流信息
			PayMentField = PayMentField & "<input type='hidden' name='transport_fee' value='0'>"   '需买方另支付的物流费如已包含在商品价格中，请填写0。如果不填，默认为0。单位为分
			PayMentField = PayMentField & "<input type='hidden' name='version' value='2'>"   
			PayMentField = PayMentField & "<input type='hidden' name='sign' value='"&v_md5info&"'>"   
		End Select  
   Set KS=Nothing
 End Sub
 
'将变量值不为空的参数组成字符串(快钱)
Function appendParam(returnStr, paramId, paramValue)
			If returnStr <> "" Then
				If paramValue <> "" Then
					returnStr=returnStr&"&"&paramId&"="&paramValue
				End If
			Else
				If paramValue <> "" Then
					returnStr=paramId&"="&paramValue
				End If
			End If
			appendParam = returnStr
End Function

%>