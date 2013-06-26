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
      $("#section_total").html("There are a total of " + data["total"] + " sections.");

      var section_types_chart = new google.visualization.PieChart(document.getElementById('section_types_chart'));
      var section_subscriptions_chart = new google.visualization.PieChart(document.getElementById('section_subscriptions_chart'));

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
    }
  })
}

function drawChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Users'
  });

  for(data_row in data) {
    row = new Array();
    row[0] = new Date(data[data_row]['date']);
    row[1] = data[data_row]['total'];
    data_table.addRow(row);
  }

  chart.draw(data_table, options);
}
