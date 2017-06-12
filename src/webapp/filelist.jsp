<%@page import="java.io.*" %>
<%@page import="java.net.*" %>
<%@page import="java.util.regex.Pattern" %>
<%@page import="java.util.regex.Matcher" %>
<html>
 <head>
  <title>eCollege file selector</title>
 </head>
 <script type="text/javascript" language="javascript">
   function anchor_passOn(fpath)
   {
 	window.opener.document.forms['importLMSForm'].selectedmoodlefile.value = fpath;
 	window.close();
   }
</script>
 <body>
<h1>select a file</h1>
<%
StringBuffer text = new StringBuffer("Oops!!! There is a problem while connecting to LAMC site. Try again.");
try
{
	String u = "http://missionparalegal.com/1-etudes" ;
	if(request.getParameter("urlData") != null)
		u = request.getParameter("urlData");
	u = u.replace(" ", "%20");
	String file = request.getRequestURI();
	URL reconstructedURL = new URL(request.getScheme(), request.getServerName(),request.getServerPort(),file);
	String imgUrl = "http://missionparalegal.com";
	text = GetContentURL(u, imgUrl, reconstructedURL.toString());
	}
	catch ( Exception e)
	{
	}
%>
<%!
	StringBuffer GetContentURL( String a_Url, String imgUrl, String reconstructedURL) throws Exception
	{
		URL l_URL = new URL(a_Url);
		
		BufferedReader l_Reader = new BufferedReader( new InputStreamReader( l_URL.openStream()));
		Pattern p_target = Pattern.compile("(href)[\\s]*=[\\s]*\"([^#\"]*)([#\"])", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
		Pattern p_img = Pattern.compile("(src)[\\s]*=[\\s]*\"([^#\"]*)([#\"])", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
		StringBuffer l_Result = new StringBuffer("") ;
		String l_InputLine = null ;

		while ((l_InputLine = l_Reader.readLine()) != null)
		{
			StringBuffer sb = new StringBuffer();
			Matcher m_img = p_img.matcher(l_InputLine);			
			if (m_img.find() && m_img.groupCount() == 3)
				{
					String content = m_img.group(2);
					String fixImg = "src=\"" + imgUrl + content  + "\"";
					l_InputLine = l_InputLine.replace(m_img.group(0),fixImg);									
				}
				
			Matcher m = p_target.matcher(l_InputLine);			
			if (m.find() && m.groupCount() == 3)
				{
					String content = m.group(2);
				
					if(content.endsWith(".zip") || content.endsWith(".mbz"))
						m.appendReplacement(sb,"href=\"javascript:anchor_passOn('" + a_Url +"/" + Matcher.quoteReplacement(content) + "')\"");
					else if (content.startsWith("/") && content.endsWith("/") )	
					{
				 		//go one directory up
						String a_Url_up = a_Url.substring(0, a_Url.lastIndexOf("/"));
						String goUp = "href=\"" + reconstructedURL + "?urlData=" + a_Url_up  + "\"";
						m.appendReplacement(sb, goUp);
					}
					else if (content.endsWith("/") )	
					{
						content = content.substring(0,content.length() -1);						
						String goBack = "href=\"" + reconstructedURL + "?urlData=" + a_Url +"/" + Matcher.quoteReplacement(content) + "\"";
						m.appendReplacement(sb, goBack);
					}
				}
			m.appendTail(sb);			
			l_Result.append(sb);
		}
		l_Reader.close();
		return( l_Result ) ;
	}
%>
<%=text%>
</body></html>