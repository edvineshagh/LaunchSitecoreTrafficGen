<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactUpdate.aspx.cs" Inherits="LaunchSitecoreTrafficGen.ContactUpdate" %>
<%@ Register TagPrefix="sc" Namespace="Sitecore.Web.UI.WebControls" Assembly="Sitecore.Kernel" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        input { width: 400px;}
    </style>
  <sc:VisitorIdentification runat="server" />
</head>

<body>
    <form id="form1" runat="server">
        <input type="submit"/>
        <br/><a href="/abandon.aspx">Abandon session</a>

    <div>
        <table>
            
            <tr><td>Contact Id:</td>
                <td><asp:Label ID="ContactId" runat="server" Text="Label"></asp:Label></td>
            </tr>

            <tr><td>RecordId to identify contact:</td>
                <td><asp:TextBox ID="RecordId" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>IP:</td>
                <td><asp:TextBox ID="Ip" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>DNS:</td>
                <td><asp:TextBox ID="Dns" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>ISP:</td>
                <td><asp:TextBox ID="Isp" runat="server"></asp:TextBox></td></tr>
            
            <!-- email -->
            <tr><td>Email:</td>
                <td><asp:TextBox ID="EmailAddress" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>Preferred email:</td>
                <td><asp:TextBox ID="PreferedEmailAddress" runat="server"></asp:TextBox> 
                    <asp:Label ID="PreferedEmailLabel" runat="server" Text="Label"></asp:Label> </td></tr>
            
            <!-- personal info -->
            <tr><td>BirthDate:</td>
                <td><asp:TextBox ID="BirthDate" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>FirstName:</td>
                <td><asp:TextBox ID="FirstName" runat="server"></asp:TextBox></td></tr>

           <tr><td>Surname:</td>
                <td><asp:TextBox ID="Surname" runat="server"></asp:TextBox></td></tr>

            <tr><td>MiddleName:</td>
                <td><asp:TextBox ID="MiddleName" runat="server"></asp:TextBox></td></tr>
            
           <tr><td>Street1:</td>
                <td><asp:TextBox ID="Street1" runat="server"></asp:TextBox></td></tr>

           <tr><td>Street2:</td>
                <td><asp:TextBox ID="Street2" runat="server"></asp:TextBox></td></tr>

           <tr><td>City:</td>
                <td><asp:TextBox ID="City" runat="server"></asp:TextBox></td></tr>

            <tr><td>Region/County:</td>
                <td><asp:TextBox ID="Region" runat="server"></asp:TextBox></td></tr>
 
            <tr><td>Metro Code:</td>
                <td><asp:TextBox ID="MetroCode" runat="server"></asp:TextBox></td></tr>
                        
           <tr><td>State:</td>
                <td><asp:TextBox ID="State" runat="server"></asp:TextBox></td></tr>
             
            <tr><td>Zip:</td>
                <td><asp:TextBox ID="ZipCode" runat="server"></asp:TextBox></td></tr>
             
            <tr><td>Country:</td>
                <td><asp:TextBox ID="Country" runat="server"></asp:TextBox></td></tr>
             
            <tr><td>Gender:</td>
                <td><asp:TextBox ID="Gender" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>Job Title:</td>
                <td><asp:TextBox ID="JobTitle" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>Contact Title:</td>
                <td><asp:TextBox ID="ContactTitle" runat="server"></asp:TextBox></td></tr>
                        
            <tr><td>Name Suffix:</td>
                <td><asp:TextBox ID="NameSuffix" runat="server"></asp:TextBox></td></tr>
            
           <tr><td>NickName:</td>
                <td><asp:TextBox ID="NickName" runat="server"></asp:TextBox></td></tr>
            

            <tr><td>Language:</td>
                <td><asp:TextBox ID="Language" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>Company:</td>
                <td><asp:TextBox ID="Company" runat="server"></asp:TextBox></td></tr>

            <tr><td>Keywords:</td>
                <td><asp:TextBox ID="Keywords" runat="server"></asp:TextBox></td></tr>

            <tr><td>Screen Width:</td>
                <td><asp:TextBox ID="ScreenWidth" runat="server"></asp:TextBox></td></tr>

            <tr><td>Screen Height:</td>
                <td><asp:TextBox ID="ScreenHeight" runat="server"></asp:TextBox></td></tr>

            <tr><td>Latitude:</td>
                <td><asp:TextBox ID="Latitude" runat="server"></asp:TextBox></td></tr>

            <tr><td>Longitude:</td>
                <td><asp:TextBox ID="Longitude" runat="server"></asp:TextBox></td></tr>

            <!-- phone number -->
            <tr><td>CountryCode:</td>
                <td><asp:TextBox ID="CountryCode" runat="server"></asp:TextBox></td></tr>

            <tr><td>Extension:</td>
                <td><asp:TextBox ID="Extension" runat="server"></asp:TextBox></td></tr>

            <tr><td>PhoneNumber1:</td>
                <td><asp:TextBox ID="PhoneNumber1" runat="server"></asp:TextBox></td></tr>

            <tr><td>MobileNumber:</td>
                <td><asp:TextBox ID="MobileNumber" runat="server"></asp:TextBox></td></tr>
            
            <tr><td>Photo:</td>
                <td><asp:fileupload runat="server" ID="FileUpload1"></asp:fileupload><br/>
                    <asp:Image ID="ImagePath1" runat="server" /></td></tr>

            <tr><td>Page Duration (seconds):</td>
                <td>Min:<asp:TextBox ID="MinPageDurationSeconds" runat="server"></asp:TextBox>
                    Max:<asp:TextBox ID="MaxPageDurationSeconds" runat="server"></asp:TextBox>
                </td></tr>
            
            <tr><td>Interaction Date/Time:</td>
                <td>Start:<asp:TextBox ID="InteractionStartDateTime" runat="server"></asp:TextBox>
                    Duration (minutes):<asp:TextBox ID="InteractionDurationMinutes" runat="server"></asp:TextBox>
                </td></tr>


        </table>
    </div>
        <input type="submit"/>
        <br/><a href="/abandon.aspx">Abandon session</a>

    </form>
</body>
</html>
