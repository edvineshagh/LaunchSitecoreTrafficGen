# LaunchSitecoreTrafficGen
LaunchSitecore Traffic Generator

This download contains a <a href="http://jmeter.apache.org/">JMeter</a> script and supporting ASP.NET files to generate factious traffic data for sample <a href="http://launchsitecore.net">LaunchSitecore</a> site so that Sitecore Experience Analytics and Experience Profile can contain sample data.  The sample data includes: name, photo, address, email, phone, referring site, search terms, and paid campaign.

Here is a sample of what you can expect:
![](https://cloud.githubusercontent.com/assets/4054499/7872632/66560b62-054e-11e5-91af-9c91a2a023dd.png)


## Copy rights ##
<div style="background-color:#eee; font-style:italic">
<p>The photo images are obtained from two sources, include: 
<ol><li><a href="randomuser.me/photos">randomuser.me/photos</a><br>
These images are made available under <a href="http://creativecommons.org/licenses/by-nc-sa/2.0/deed.en">Creative Commons rights</a>.</li>
<li><a href="http://vis-www.cs.umass.edu/lfw/">Labeled faces in the wild</a></a><br>
 These images are compiled by the University of <a href="http://vis-www.cs.umass.edu/">Massachusetts computer vision lab</a>.  Many of these images are photographs of athletes, celebrities, government officials, etc; therefore, it is safe to assume that these photos may not be used in a commercial capacity without explicit permission.<br>
 These images are identified by file prefix 2_ with inside the /DataFolder/Images folder. 
<img src="https://cloud.githubusercontent.com/assets/4054499/7872994/d5ceec9a-0551-11e5-8b64-183c5e9390db.png">
</li>
</ol>
  
</div>

## Preparing the website
Before using the JMeter script, you need to add a few files to Sitecore, so that visitor behaviors can be mutated.  To prepare the website, you can use the Sitecore installation package.

Alternatively, for a manual install, follow these steps:

* `ContactUpdate.aspx` and `abandon.aspx`to the root of the website.

* Copy the configuration file `LaunchSitecoreTrafficGen.Sitecore.Analytics.Tracking` to Sitecore's `/App_config/Include` folder.

* Copy the `LaunchSitecoreTarafficGen.dll` to Sitecore `website/bin `folder.

The JMeter script generates traffic by issuing GET/POST request to your installation of launchsitecore and then conclude by issuing a request to `~/ContactUpdate.aspx` and  `abandon.aspx`.  The `ContactUpdate.aspx` enables a developer to create/update contact profile in an ad-hoc manner.  The script, uses the same web form to mutate visitor activities.  


##Using the JMeter scrip##
When you first open the script, you’ll notice that the data files are defined as CSV files at the top of the JMeter script.  These data files are located `DataFolder` of this distribution. 

First, specify the target website hostname by clicking on **Default host name** node.  All the web request shall use this host for the base request.
![](https://cloud.githubusercontent.com/assets/4054499/7872582/0714fd98-054e-11e5-96ba-352054a96fdf.png)

You can specify the duration of each visitor per page by updating the **Random Page Duration On Submit value** node.  The benefit of this approach (as appose to sleep timer) is that the script can continue executing with no delays.
![](https://cloud.githubusercontent.com/assets/4054499/7872588/072d41c8-054e-11e5-8bc4-7d0cd9b0b78e.png)
 

The  **Main Thread Group** node of the JMeter is used to configure the number of virtual visitors to simulate.  Each iteration is a different user because the **HTTP Cookie Manager** node resets the cookies at the end of each iteration.
![](https://cloud.githubusercontent.com/assets/4054499/7872584/072778ec-054e-11e5-872a-a4d7eba1bc1e.png)

If you intend to run the script multiple times to the same Sitecore instance, you may wish to skip existing imported data records.  When running the test multiple times, there is a need to skip existing records; therefore, the “**If controller – skip top records**” node is provided.  By updating the condition field of this node, you effectively skip specified number of records during your run.
![](https://cloud.githubusercontent.com/assets/4054499/7872743/531fcfa0-054f-11e5-9ded-58e6b6e15d34.png)

As convention, each contact has two numbers: an office number and a mobile number.  To easily identify the phone numbers, the office numbers are even, and the users mobile numbers are the next sequential odd number.  For example, if the contact office is 200-300-1000, then the mobile number will be 200-300-1001.
![](https://cloud.githubusercontent.com/assets/4054499/7872587/0729697c-054e-11e5-8ffb-ab982efe2091.png)

<div style="background-color:#eee">
Telephone area-code and prefix correspond to appropriate city, state, and zip code.  The Geo-location (latitude and longitude) correspond to the zip code. However, the contact name and street address are factitious.
</div>

Historic data is handled by **NumberOfInteractions** and **IterationPastDaysCounter** nodes of the JMeter script.  The former is responsible for generating a random number of interaction for each contact; the latter is responsible for specifying the number of days that each interaction should be apart.
![](https://cloud.githubusercontent.com/assets/4054499/7872586/0728bd6a-054e-11e5-9ab1-c58fd738f287.png)
![](https://cloud.githubusercontent.com/assets/4054499/7872583/07154730-054e-11e5-81b5-e90d02633f23.png)

A special node **Generate Variables**, is responsible for creating unique and repeatable data elements for each contact, such as: Birth date, name suffix, salutation.  These elements utilize the full name [hash code](https://msdn.microsoft.com/en-us/library/system.object.gethashcode%28v=vs.110%29.aspx) to re-generate user data.  This was done because each user photo is unique and associated with a name.  
![](https://cloud.githubusercontent.com/assets/4054499/7872579/071050b8-054e-11e5-8fb2-44bb067005e9.png)

Though you wont need to update the the above variables, you may need to change the frequency of adding a Sitecore campaign code to the landing page.  The frequency of the campaign codes, specified in the **CSV SC Campaign Tracking**, is handled in the node **set landingPageQueryString var**.  In below example, the campaign query string is add to the landing page URL 80% of the time.
![](https://cloud.githubusercontent.com/assets/4054499/7872578/070e78a6-054e-11e5-8206-70311e94e9f9.png)

The **Random Controller – Landing Page** node insures that only a small set of pages are randomly selected as the landing page.  

Subsequent **Random If Controller** insure that the the requesting pages are not called all the time; thereby, giving varying the visitor page requests.</p>
![](https://cloud.githubusercontent.com/assets/4054499/7872585/0728cfd0-054e-11e5-892d-98e2338b80ad.png)

Lastly, the **Update Contact** is called to change the visitor history information and commit data into the database by calling the `~/ContactUpdate.aspx` and `~/abandon.aspx` respectively.

