<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
    
<%
/**
 * 直连模式
 * 技术联系人 陈荣江 17602115638 微信同号
 * 文档地址 https://docs.glocash.com/
 * 商户后台 https://portal.glocashpayment.com/#/login
 *
 */

/**
 * 测试卡
 *   Visa | 4907639999990022 | 12/2020 | 029 paid
 *   MC   | 5546989999990033 | 12/2020 | 464 paid
 *   Visa | 4000000000000002 | 01/2022 | 237 | 14  3ds paid
 *   Visa | 4000000000000028 | 03/2022 | 999 | 54  3ds paid
 *   Visa | 4000000000000051 | 07/2022 | 745 | 94  3ds paid
 *   MC   | 5200000000000007 | 01/2022 | 356 | 34  3ds paid
 *   MC   | 5200000000000023 | 03/2022 | 431 | 74  3ds paid
 *   MC   | 5200000000000106 | 04/2022 | 578 | 104 3ds paid
 *
 *  想测试失败 可以填错年月日或者ccv即可
 */

//TODO 请仔细查看TODO的注释 请仔细查看TODO的注释 请仔细查看TODO的注释

String sandbox_url = "https://sandbox.glocashpayment.com/gateway/payment/ccDirect"; //测试地址
String live_url    = "https://pay.glocashpayment.com/gateway/payment/ccDirect"; //正式地址

//秘钥 测试地址请用测试秘钥 正式地址用正式秘钥 请登录商户后台查看
String sandbox_key = ""; //TODO 测试秘钥 商户后台查看
String live_key = ""; //TODO 正式秘钥 商户后台查看(必须材料通过以后才能使用)

long timeStampSec = System.currentTimeMillis()/1000;
String timestamp = String.format("%010d", timeStampSec);

String timetemp = new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date(timeStampSec * 1000));
String timetemp2 = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date(timeStampSec * 1000));

java.util.Random rand = new java.util.Random();

//支付参数
java.util.Map<String, String> data = new java.util.HashMap<String, String>();
data.put("REQ_SANDBOX", "1");  //TODO 是否开启测试模式 0 正式环境 1 测试环境
data.put("REQ_EMAIL", "rongjiang.chen@witsion.com");    //TODO 需要换成自己的 商户邮箱 商户后台申请的邮箱
data.put("REQ_TIMES", timestamp);    //请求时间
data.put("REQ_INVOICE", "TEST"+timetemp+rand.nextInt(1000)+9000);    //订单号
data.put("REQ_MERCHANT", "Merchant Name");  //商户名
data.put("REQ_APPID", "380");  //应用ID
data.put("CUS_EMAIL", "rongjiang.chen@witsion.com");    //客户邮箱
data.put("BIL_METHOD", "C01");    //请求方式
data.put("BIL_PRICE", "1");    //价格
data.put("BIL_CURRENCY", "USD");    //币种
data.put("BIL_CC3DS", "1");    //是否开启3ds 1 开启 0 不开启
data.put("URL_SUCCESS", "http://hs.crjblog.cn/success.php");    //支付成功跳转页面
data.put("URL_FAILED", "http://hs.crjblog.cn/failed.php");    //支付失败跳转页面
data.put("URL_NOTIFY", "http://hs.crjblog.cn/notify.php");    //异步回调跳转页面

java.util.Map<String, String> card = new java.util.HashMap<String, String>();
card.put("BIL_CCNUMBER", "4000000000000002");    //信用卡卡号
card.put("BIL_CCHOLDER", "john smith");    //信用卡持卡人姓名
card.put("BIL_CCEXPM", "04");    //信用卡过期月份
card.put("BIL_CCEXPY", "2022");    //信用卡过期年份
card.put("BIL_CCCVV2", "123");    //信用卡CVV2码
card.put("BIL_IPADDR", "58.247.45.36");    //付款人IP
card.put("BIL_GOODSNAME", "#gold#Runescape/OSRS Old School/ 10M Gold");    //TODO 商品名称必填 而且必须是正确的否则无法结算
card.put("BIL_GOODS_URL", "https://www.merchant.com/goods/30");    //买家购买商户的链接

//更多支付参数请参考文档 经典模式->附录2：付款请求参数表
//签名
String url = data.get("REQ_SANDBOX")=="1"?sandbox_url:live_url;//根据REQ_SANDBOX调整地址
String key = data.get("REQ_SANDBOX")=="1"?sandbox_key:live_key;//根据REQ_SANDBOX调整秘钥

out.println(url);

java.io.File file = new java.io.File("");
String filePath = file.getCanonicalPath();

if(request.getParameter("BIL_CCNUMBER")!=null){
	for(java.util.Map.Entry<String, String> entry : card.entrySet()) {
		data.put(entry.getKey(),request.getParameter(entry.getKey()));
	}
	
	String reg_sign=key+data.get("REQ_TIMES")+data.get("REQ_EMAIL")+data.get("REQ_INVOICE")+data.get("CUS_EMAIL")+data.get("BIL_METHOD")+data.get("BIL_PRICE")+data.get("BIL_CURRENCY");
	data.put("REQ_SIGN", getSHA256StrJava(reg_sign));
	
	try{
		java.io.File files =new java.io.File(filePath+"\\ccDirect.log");
		java.io.Writer outfile =new java.io.FileWriter(files,true);
		outfile.write(timetemp2+"\r\n");
		outfile.write(url+"\r\n");
        for(java.util.Map.Entry<String, String> entry : data.entrySet()) {
        	outfile.write(entry.getKey()+": "+entry.getValue()+"\r\n");
        }
		outfile.close();
		
        String param="";
        for(java.util.Map.Entry<String, String> entry : data.entrySet()) {
        	param += entry.getKey()+"="+entry.getValue()+"&";
        }
        param=param.substring(0,param.length()-1);
        
        String result=sendPost(url, param);
        com.alibaba.fastjson.JSONObject parseData = com.alibaba.fastjson.JSONObject.parseObject(result);
        
		out.println("<pre>");
		out.println(result);
        out.println("</pre>");
        
        if(parseData.getString("REQ_ERROR")!=null){
    		out.println("<pre>");
    		for(String keystr:parseData.keySet()){
    			out.println(keystr+": "+parseData.get(keystr)+"<br/>");
    		}
            out.println("</pre>");
        	return;
        }
        
		outfile =new java.io.FileWriter(files,true);
		outfile.write("\r\n");
		outfile.write(result+"\r\n");
		for(String keystr:parseData.keySet()){
			outfile.write(keystr+": "+parseData.get(keystr)+"\r\n");
		}
		outfile.close();
        
        if(result.length()>0 && !parseData.isEmpty()){
        	response.sendRedirect(parseData.getString("URL_CC3DS"));
        }
        else{
        	out.println(result);
    		for(String keystr:parseData.keySet()){
    			out.println(keystr+": "+parseData.get(keystr)+"<br/>");
    		}
        }
        
	}
	catch(Exception e){
		out.println("<pre>");
		out.println(e.getMessage());
        out.println("</pre>");
	}
	
}

%>

<%!
private String getSHA256StrJava(String str){
	java.security.MessageDigest messageDigest;
	String encodeStr = "";
	try {
		messageDigest = java.security.MessageDigest.getInstance("SHA-256");
		messageDigest.update(str.getBytes("UTF-8"));
		encodeStr = byte2Hex(messageDigest.digest());
	} catch (java.security.NoSuchAlgorithmException e) {
		e.printStackTrace();
	} catch (java.io.UnsupportedEncodingException e) {
		e.printStackTrace();
	}
	return encodeStr;
}
private String byte2Hex(byte[] bytes){
	StringBuffer stringBuffer = new StringBuffer();
	String temp = null;
	for (int i=0;i<bytes.length;i++){
		temp = Integer.toHexString(bytes[i] & 0xFF);
		if (temp.length()==1){
			//1得到一位的进行补0操作
			stringBuffer.append("0");
		}
		stringBuffer.append(temp);
	}
	return stringBuffer.toString();
}
public String sendPost(String url, String param) {
	//根据实际请求需求进行参数封装
    java.io.PrintWriter out = null;
    java.io.BufferedReader in = null;
    String result = "";
    try {
        java.net.URL realUrl = new java.net.URL(url);
        // 打开和URL之间的连接
        java.net.URLConnection conn = realUrl.openConnection();
        // 发送POST请求必须设置如下两行
        conn.setDoOutput(true);
        conn.setDoInput(true);

        conn.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)");

        //获取URLConnection对象对应的输出流
        out = new java.io.PrintWriter(conn.getOutputStream());
        // 发送请求参数
        out.print(param);
        // flush输出流的缓冲
        out.flush();
        // 定义BufferedReader输入流来读取URL的响应
        in = new java.io.BufferedReader(new java.io.InputStreamReader(conn.getInputStream()));
        String line;
        while ((line = in.readLine()) != null) {
            result += line;
        }
    } catch (Exception e) {
        System.out.println("发送 POST 请求出现异常！"+e);
        e.printStackTrace();
    }
    //使用finally块来关闭输出流、输入流
    finally{
        try{
            if(out!=null){
                out.close();
            }
            if(in!=null){
                in.close();
            }
        }
        catch(java.io.IOException ex){
            ex.printStackTrace();
        }
    }
    return result;
}
%>
    
<!DOCTYPE html>
<html>
<body>
<form method="post" action="#">
	<% for(java.util.Map.Entry<String, String> entry : card.entrySet()) { %>
        <div><span style="display: inline-block;width: 150px;text-align: right;padding-right: 15px;"><%=entry.getKey() %>
                :</span><input value="<%=entry.getValue() %>" name="<%=entry.getKey()%>"/></div>
    <% } %>
    <input type="submit" value="提交"/>
</form>
</body>
</html>