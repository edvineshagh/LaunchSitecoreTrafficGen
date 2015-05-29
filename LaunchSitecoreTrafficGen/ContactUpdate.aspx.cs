using System;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using Sitecore.Analytics;
using Sitecore.Analytics.Model;
using Sitecore.Analytics.Model.Entities;
using Sitecore.Analytics.Tracking;
using Sitecore.Configuration;
using Sitecore.ExperienceExplorer.Business.Utilities;
using DateTime = System.DateTime;

namespace LaunchSitecoreTrafficGen
{
    public partial class ContactUpdate : System.Web.UI.Page
    {
        private readonly string AddressHomeLabel = "home";
        private readonly string AddressOfficeLabel = "office";
        private readonly string EmailHomeLabel = "home";
        private readonly string EmailOfficeLabel = "office";
        private readonly string PhoneMobileLabel = "mobile";
        private readonly string PhoneOfficeLabel = "office";
        private readonly TextInfo textInfo = Thread.CurrentThread.CurrentCulture.TextInfo;

        private string _visitorIp;

        //protected System.Web.UI.HtmlControls.HtmlInputFile Photo;


        private string GetInteractionId()
        {
            string id = RecordId.Text;

            if (string.IsNullOrWhiteSpace(id)) 
            {
                id = FirstName.Text +
                     Surname.Text +
                     Gender.Text +
                     JobTitle.Text +
                     ContactTitle.Text +
                     MiddleName.Text +
                     NickName.Text +
                     NameSuffix.Text;
            }

            return (string.IsNullOrWhiteSpace(id) ? Tracker.Current.Interaction.ContactId.ToString() : id);
        }

        protected void Page_Load(object sender, EventArgs e)
        {


            _visitorIp = Ip.Text
                      ?? Request["visitorIp"]
                      ?? Request.Headers["visitorIp"]
                      ?? Request.Headers["Ip"]
                      ?? HttpContext.Current.Request.UserHostAddress;

            if (Sitecore.Analytics.Tracker.Current == null
                || Sitecore.Analytics.Tracker.Current.Contact == null)
            {
                Sitecore.Analytics.Tracker.Initialize();
            }




            
            PreferedEmailLabel.Text = string.Format("({0}, {1})", EmailOfficeLabel, EmailHomeLabel);
            

            if (!IsPostBack) //Request.HttpMethod == "POST")}
            {
                ContactId.Text = Tracker.Current.Session.Contact.ContactId.ToString();
                PopulateForm(Tracker.Current.Session.Contact);
            }
            else
            {
                Tracker.Current.Session.Identify(GetInteractionId());

                //var contact = contactManager.LoadContactReadOnly(interaction.ContactId);

                var contact = Tracker.Current.Session.Contact;

                //contact.LoadHistorycalData(visitsToLoad: 1);
                ContactId.Text = contact.ContactId.ToString();

                var interaction = AnalyticsUtil.VisitContext; //Tracker.Current.Interaction;

                
                WhoIsInformation geoIpData = GetWhoIsInfo();
                PopulateFacetFromFormPost(contact);
                interaction.Ip = IPAddress.Parse(_visitorIp).GetAddressBytes();

                
                
                if (Regex.IsMatch(ScreenWidth.Text,@"^\s*\d+\s*$") &&  Regex.IsMatch(ScreenHeight.Text,@"^\s*\d+\s*$"))
                {
                  
                    interaction.ScreenInfo.ScreenWidth = Int32.Parse(ScreenWidth.Text.Trim());
                    interaction.ScreenInfo.ScreenHeight = Int32.Parse(ScreenHeight.Text.Trim());

                }
                // * this line is not needed for Jmeter since Referer is used
                // interaction.Keywords = Keywords.Text;
               
                interaction.SetGeoData(geoIpData);
                
                DateTime interactionStartDateTime = interaction.StartDateTime;
                DateTime.TryParse(InteractionStartDateTime.Text, out interactionStartDateTime);
                
                int interactionDuration = 20;
                Int32.TryParse(InteractionDurationMinutes.Text, out interactionDuration);

                interaction.StartDateTime = interactionStartDateTime;
                interaction.EndDateTime = DateTime.Now.AddMinutes(interactionDuration);

                int minPageDurationSeconds=0, maxPageDurationSeconds=0;
                Int32.TryParse(MinPageDurationSeconds.Text, out minPageDurationSeconds);
                Int32.TryParse(MaxPageDurationSeconds.Text, out maxPageDurationSeconds);
                maxPageDurationSeconds = Math.Max(maxPageDurationSeconds, minPageDurationSeconds);

                if (minPageDurationSeconds > 0 && maxPageDurationSeconds > 0)
                {
                    Random r = new Random();
                    interaction.Pages.ToList().ForEach(page => page.Duration = r.Next(minPageDurationSeconds * 1000, maxPageDurationSeconds * 1000));
                }

                //interaction.EndDateTime = DateTime.Now.AddMonths(-40);
                //interaction.UpdateGeoIpData();         
                //interaction.UpdateLocationReference();
                interaction.AcceptModifications();
                
                
                var contactManager =
                    Factory.CreateObject("tracking/contactManager", true) as ContactManager;


                contactManager.FlushContactToXdb(contact);
            }


        }

       



        private WhoIsInformation GetWhoIsInfo()
        {
            var info = new WhoIsInformation
            {
                AreaCode = PhoneNumber1.Text.Length > 0 ? Regex.Match(PhoneNumber1.Text, @"\d\d\d").Value : string.Empty,
                BusinessName = Company.Text,
                City = City.Text,
                Country = Country.Text,
                PostalCode = ZipCode.Text,
                Dns = Dns.Text,
                Isp = Isp.Text,
                IsUnknown = false,
                Latitude = Double.Parse(Longitude.Text),
                Longitude = Double.Parse(Latitude.Text),
                MetroCode = MetroCode.Text,
                Region = Region.Text,
                Url = Company.Text

            };

            return info;
        }



        private void PopulateFacetFromFormPost(Contact contact)
        {

            var facetPersonalInfo = contact.GetFacet<IContactPersonalInfo>("Personal");
            facetPersonalInfo.BirthDate = DateTime.Parse(BirthDate.Text);
            facetPersonalInfo.FirstName = FirstName.Text;
            facetPersonalInfo.Surname = Surname.Text;
            facetPersonalInfo.Gender = Gender.Text;
            facetPersonalInfo.JobTitle = JobTitle.Text;
            facetPersonalInfo.Title = ContactTitle.Text; 
            facetPersonalInfo.MiddleName = MiddleName.Text;
            facetPersonalInfo.Nickname = NickName.Text;
            facetPersonalInfo.Suffix = NameSuffix.Text;

            

            var facetAddress = contact.GetFacet<IContactAddresses>("Addresses");

            var addressOffice = facetAddress.Entries.Contains(AddressOfficeLabel)
                ? facetAddress.Entries[AddressOfficeLabel]
                : facetAddress.Entries.Create(AddressOfficeLabel);

            var addressHome = facetAddress.Entries.Contains(AddressHomeLabel)
                ? facetAddress.Entries[AddressHomeLabel]
                : facetAddress.Entries.Create(AddressHomeLabel);

            addressHome.City = addressOffice.City = City.Text;
            addressHome.Country = addressOffice.Country = Country.Text;
            addressHome.PostalCode = addressOffice.PostalCode = ZipCode.Text;
            addressHome.StreetLine1 = "222" + (addressOffice.StreetLine1 = Street1.Text) + " #222";
            addressHome.StreetLine2 = addressOffice.StreetLine2 = Street2.Text;
            addressHome.StateProvince = addressOffice.StateProvince = State.Text;

            if (Latitude.Text.Length > 0) addressHome.Location.Latitude = addressHome.Location.Latitude = float.Parse(Latitude.Text);
            if (Latitude.Text.Length > 0) addressHome.Location.Longitude = addressOffice.Location.Longitude = float.Parse(Longitude.Text);

            if (Latitude.Text.Length > 0)
            {
                addressOffice.Location.Latitude = float.Parse(Latitude.Text);
                addressHome.Location.Latitude = float.Parse(Latitude.Text + "222");
            }
            if (Latitude.Text.Length > 0)
            {
                addressOffice.Location.Longitude = float.Parse(Longitude.Text);
                addressHome.Location.Longitude = float.Parse(Longitude.Text + "222");
            }


            facetAddress.Preferred = AddressOfficeLabel;


            //var facetCommunication = contact.GetFacet<IContactCommunicationProfile>("Communication Profile");

            var facetPhone = contact.GetFacet<IContactPhoneNumbers>("Phone Numbers");
            (facetPhone.Entries.Contains(PhoneOfficeLabel)
                ? facetPhone.Entries[PhoneOfficeLabel]
                : facetPhone.Entries.Create(PhoneOfficeLabel)).Number = PhoneNumber1.Text;

            (facetPhone.Entries.Contains(PhoneMobileLabel)
                ? facetPhone.Entries[PhoneMobileLabel]
                : facetPhone.Entries.Create(PhoneMobileLabel)).Number = MobileNumber.Text;

            facetPhone.Preferred = PhoneOfficeLabel;


            var facetPreferences = contact.GetFacet<IContactPreferences>("Preferences"); // Language
            facetPreferences.Language = Language.Text;

            var facetEmail = contact.GetFacet<IContactEmailAddresses>("Emails");
            (facetEmail.Entries.Contains(EmailOfficeLabel)
                ? facetEmail.Entries[EmailOfficeLabel]
                : facetEmail.Entries.Create(EmailOfficeLabel)).SmtpAddress = EmailAddress.Text.Replace("@", "." + EmailOfficeLabel + "@");

            (facetEmail.Entries.Contains(EmailHomeLabel)
                ? facetEmail.Entries[EmailHomeLabel]
                : facetEmail.Entries.Create(EmailHomeLabel)).SmtpAddress = EmailAddress.Text.Replace("@", "." + EmailHomeLabel + "@"); ;

            facetEmail.Preferred = EmailOfficeLabel;

            var facetPicture = contact.GetFacet<IContactPicture>("Picture");


            if (FileUpload1.HasFile)
            {
                facetPicture.Picture = FileUpload1.FileBytes;
                facetPicture.MimeType = FileUpload1.PostedFile.ContentType;
            }
        }

        private void PopulateForm(Contact contact)
        {

            var facetPersonalInfo = contact.GetFacet<IContactPersonalInfo>("Personal");
            BirthDate.Text = facetPersonalInfo.BirthDate.ToString();

            FirstName.Text = facetPersonalInfo.FirstName;
            Surname.Text = facetPersonalInfo.Surname;
            Gender.Text = facetPersonalInfo.Gender;
            JobTitle.Text = facetPersonalInfo.JobTitle;
            MiddleName.Text = facetPersonalInfo.MiddleName;
            NickName.Text = facetPersonalInfo.Nickname;
            NameSuffix.Text = facetPersonalInfo.Suffix;
            ContactTitle.Text = facetPersonalInfo.Title;

            var facetAddress = contact.GetFacet<IContactAddresses>("Addresses");

            var addressOffice = facetAddress.Entries.Contains(AddressOfficeLabel)
                ? facetAddress.Entries[AddressOfficeLabel]
                : facetAddress.Entries.Create(AddressOfficeLabel);

            var addressHome = facetAddress.Entries.Contains(AddressHomeLabel)
                ? facetAddress.Entries[AddressHomeLabel]
                : facetAddress.Entries.Create(AddressHomeLabel);

            City.Text = addressOffice.City;
            Country.Text = addressOffice.Country;
            ZipCode.Text = addressOffice.PostalCode;
            Street1.Text = addressOffice.StreetLine1;
            Street2.Text = addressOffice.StreetLine2;
            State.Text = addressHome.StateProvince;

            Latitude.Text = addressOffice.Location == null ? "" : addressHome.Location.Latitude.ToString();
            Longitude.Text = addressOffice.Location == null ? "" : addressHome.Location.Longitude.ToString();


            facetAddress.Preferred = AddressOfficeLabel;


            var facetPhone = contact.GetFacet<IContactPhoneNumbers>("Phone Numbers");
            (facetPhone.Entries.Contains(PhoneOfficeLabel)
                ? facetPhone.Entries[PhoneOfficeLabel]
                : facetPhone.Entries.Create(PhoneOfficeLabel)).Number = PhoneNumber1.Text;

            (facetPhone.Entries.Contains(PhoneMobileLabel)
                ? facetPhone.Entries[PhoneMobileLabel]
                : facetPhone.Entries.Create(PhoneMobileLabel)).Number = MobileNumber.Text;


            PhoneNumber1.Text = facetPhone.Entries.Contains(PhoneOfficeLabel)
                ? facetPhone.Entries[PhoneOfficeLabel].Number
                : "";


            MobileNumber.Text = facetPhone.Entries.Contains(PhoneMobileLabel)
                ? facetPhone.Entries[PhoneMobileLabel].Number
                : "";

            facetPhone.Preferred = PhoneOfficeLabel;


            var facetPreferences = contact.GetFacet<IContactPreferences>("Preferences"); // Language
            facetPreferences.Language = Language.Text;

            var facetEmail = contact.GetFacet<IContactEmailAddresses>("Emails");

            EmailAddress.Text = facetEmail.Entries.Contains(EmailOfficeLabel)
                ? facetEmail.Entries[EmailOfficeLabel].SmtpAddress
                : "";

            PreferedEmailAddress.Text = facetEmail.Preferred;

            //   ImagePath.Text =
            //   ImagePath1.ImageUrl = 

            var facetPicture = contact.GetFacet<IContactPicture>("Picture");


            if (FileUpload1.FileBytes.LongLength > 0)
            {
                facetPicture.Picture = FileUpload1.FileBytes;
                facetPicture.MimeType = FileUpload1.PostedFile.ContentType;
            }
        }


    }
}