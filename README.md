<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="Sitecore.Data.Items" %>
<%@ Import Namespace="Sitecore.Layouts" %>
<%@ Import Namespace="USM.EmployerOnline.Web" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Sitecore.SecurityModel" %>
<%@ Import Namespace="Sitecore.Data" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        using (new SecurityDisabler())
        {
            var startPath = "{58A044D6-9C5E-4FEE-B824-F7414AA5C957}";
            var db = Sitecore.Data.Database.GetDatabase("master");
            var startItem = db.GetItem(startPath);
            var descendants = startItem.Axes.GetDescendants();
            var pages = descendants.Concat(new Item[] { startItem });

            var report = new Report();

            foreach (var page in pages)
            {
                var sharedLayout = page.Fields[Sitecore.FieldIDs.LayoutField];
                // var finalLayout = no such thing in 7.2

                var xml = Sitecore.Data.Fields.LayoutField.GetFieldValue(sharedLayout);

                // default layout
                var layout = Sitecore.Layouts.LayoutDefinition.Parse(xml).Devices[0] as DeviceDefinition;

                report.Pages.Add(new SitecorePage
                {
                    Layout = layout.Layout,
                    Path = page.Paths.Path,
                    Template = page.TemplateName,
                    Renderings = layout.Renderings.ToArray().Cast<RenderingDefinition>().Select(x => FromRendering(x, db)).ToList()
                });

            }

            Summary.Text += string.Format("<p><b>Page Count</b> {0}</p>", report.Pages.Count);
            Summary.Text += string.Format("<p><b>Distinct Template Count</b> {0}</p>", report.Pages.Select(x=>x.Template).Distinct().Count());
            Summary.Text += string.Format("<p><b>Distinct Page Layout Count</b> {0}</p>", report.Pages.Select(x=>x.Layout).Distinct().Count());
            Summary.Text += string.Format("<p><b>Distinct Rendering Count</b> {0}</p>", report.Pages.SelectMany(x => x.Renderings).Distinct().Count());
            Summary.Text += string.Format("<p><b>List of Distinct Renderings</b> {0}</p>", ListOfDistinctRenderings(report));

            Output.Text = JsonConvert.SerializeObject(report);
        }
    }

    private string ListOfDistinctRenderings(Report report)
    {
        var sb = new StringBuilder();

        foreach (var r in report.Pages.SelectMany(x => x.Renderings).Distinct())
        {
            sb.AppendLine("<br/>" + r);
        }

        return sb.ToString();
    }

    private string FromRendering(RenderingDefinition rendering, Database db)
    {
        using (new SecurityDisabler())
        {
            var item = db.GetItem(rendering.ItemID);

            if (item == null) return rendering.ItemID + " (not found)";

            return item.Name + " (" + item.Paths.Path + ")";
        }
    }

    public class Report
    {
        public Report()
        {
            Pages = new List<SitecorePage>();
        }

        public List<SitecorePage> Pages { get; set; }
    }

    public class SitecorePage
    {
        public SitecorePage()
        {
            Renderings = new List<string>();
        }

        public string Path { get; set; }
        public List<string> Renderings { get; set; }
        public string Layout { get; set; }
        public string Template { get; set; }
    }
</script>

<body>
    <form id="form1" runat="server">
        <div>
            <asp:Literal runat="server" Id="Summary"></asp:Literal>
            <hr/>
            <asp:Literal runat="server" ID="Output"></asp:Literal>
        </div>
    </form>
</body>
</html>
