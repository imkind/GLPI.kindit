document.writeln('<table width=\"98%\" border=\"0\" align=\"center\">')
document.writeln('<form id=\"SearchForm\" name=\"SearchForm\" method=\"get\" action=\"/plus/Search.asp\">')
document.writeln('  <tr>')
document.writeln('    <td align=\"center\"><select name=\"SearchType\">')
document.writeln('        <option value=\"1\">标 题</option>')
document.writeln('        <option value=\"2\">内 容</option>')
document.writeln('        <option value=\"3\">作 者</option>')
document.writeln('        <option value=\"4\">录入者</option>')
document.writeln('        <option value=\"5\">关键字</option>')
document.writeln('      </select>')
document.writeln('        <select name=\"ClassID\" style=\"width:150px\">')
document.writeln('          <option value=\"0\" selected=\"selected\">所有栏目</option>')
document.writeln('<option value=\'20137114368279\'>首页 </option><option value=\'20134079706863\'>──进入首页 </option><option value=\'20135931372544\'>工作日志 </option><option value=\'20135870681816\'>──查看工作日志 </option><option value=\'20138864749401\'>HelpDesk </option><option value=\'20134643660789\'>──创建HelpDesk记录 </option><option value=\'20136578506197\'>──查看HelpDesk记录 </option><option value=\'20133574905980\'>操作流程 </option><option value=\'20137478235535\'>──IT部 </option><option value=\'20134348231008\'>──销售部 </option><option value=\'20133287283132\'>──网站部 </option><option value=\'20134735091973\'>技术姿势 </option><option value=\'20130252743067\'>──OutLook </option><option value=\'20136109697231\'>──IE </option><option value=\'20130220293802\'>──MDT </option><option value=\'20139602143868\'>──Symantec </option><option value=\'20130885127343\'>──Dell </option><option value=\'20132576959087\'>──HP Print </option><option value=\'20137226759937\'>──Proxy </option><option value=\'20139011613468\'>──Adobe </option><option value=\'20132800555845\'>搜索 </option><option value=\'20130200088646\'>──站内搜索 </option><option value=\'20139158470928\'>幻灯片 </option>        </select>')
document.writeln('        <input name=\"KeyWord\" type=\"text\" class=\"textbox\"  value=\"关键字\" onfocus=\"this.select();\"/>')
document.writeln('        <input name=\"ChannelID\" value=\"1\" type=\"hidden\" />')
document.writeln('        <input type=\"submit\" class=\"inputButton\" name=\"Submit\" value=\"搜 索\" /></td>')
document.writeln('  </tr>')
document.writeln('</form>')
document.writeln('</table>')
