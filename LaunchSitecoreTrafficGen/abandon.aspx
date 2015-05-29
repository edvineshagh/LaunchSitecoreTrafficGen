<%@ Page language="c#" %>
<script runat="server">
  
  void Page_Load(object sender, System.EventArgs e) {
    Response.Write("Session Abandoned<BR>");
	Session[DateTime.Now.ToString()] = DateTime.Now.ToString();
	Session.Abandon();
      
      
    //	Response.Redirect("/");

  }
  
</script>  
