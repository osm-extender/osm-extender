google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: "/statistics/sections.json",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var addons_desired_steps = 5;

      $("#section_total").html("The users of OSM Extender have access to " + data["total"] + " unique sections.");

      var section_types_chart = new google.visualization.PieChart(document.getElementById('section_types_chart'));
      var section_subscriptions_chart = new google.visualization.PieChart(document.getElementById('section_subscriptions_chart'));
      var section_addons_chart = new google.visualization.BarChart(document.getElementById('section_addons_chart'));

      var section_types_options = {
        legend: {position: 'bottom', textStyle: {fontSize: 10}},
        width: 400, height: 500,
        colors: ['#0099FF', '#33CC00', '#006666', '#999966', '#CC9966', '#606060'],
        pieSliceText: "percentage",
        title: "Section Types",
        titleTextStyle: {fontSize: 25}
      };
      var section_types_data = google.visualization.arrayToDataTable([
        ["Type", "Number"],
        ["Beavers", data["section_types"]["beavers"]],
        ["Cubs", data["section_types"]["cubs"]],
        ["Scouts", data["section_types"]["scouts"]],
        ["Explorers", data["section_types"]["explorers"]],
        ["Adults", data["section_types"]["adults"]],
        ["Waiting List", data["section_types"]["waiting"]],
       ]);
      section_types_chart.draw(section_types_data, section_types_options);

      var section_subscriptions_options = {
        legend: {position: 'bottom'},
        width: 400, height: 500,
        colors: ['#CDCD00', '#C0C0C0', '#EEC900'],
        pieSliceText: "percentage",
        title: "Subscription Levels",
        titleTextStyle: {fontSize: 25}
      };
      var section_subscriptions_data = google.visualization.arrayToDataTable([
        ["Type", "Number"],
        ["Bronze", data["subscription_levels"]["1"]],
        ["Silver", data["subscription_levels"]["2"]],
        ["Gold", data["subscription_levels"]["3"]],
       ]);
      section_subscriptions_chart.draw(section_subscriptions_data, section_subscriptions_options);

      var section_addons_options = {
        focusTarget: 'category',
        legend: {
          position: 'none'
        },
        hAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['addons']['max_value'], addons_desired_steps)
          }
        },
        width: 1000, height: 350,
        title: "OSM Addon Usage",
        titleTextStyle: {fontSize: 25}
      };
      section_addons_options.hAxis.maxValue = graphStepSize(data['addons']['max_value'], addons_desired_steps) * (section_addons_options.hAxis.gridlines.count - 1);
      var section_addons_data = new google.visualization.DataTable();
      section_addons_data.addColumn({
        type: 'string',
        label: 'OSM Addon'
      });
      section_addons_data.addColumn({
        type: 'number',
        label: 'Sections using it'
      });
      for(var key in data['addons']['data']) {
        section_addons_data.addRow([key, data['addons']['data'][key]]);
      }
      section_addons_chart.draw(section_addons_data, section_addons_options);
    }
  })
}
