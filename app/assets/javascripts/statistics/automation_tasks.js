google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: 'automation_tasks.json',
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      $("#counts").html("There are " + data["tasks_count"] + " tasks, which have been created by " + data["users_count"] + " users for " + data["sections_count"] + " different sections.");

      var item_desired_steps = 5;

      var item_chart = new google.visualization.BarChart(document.getElementById('item_chart'));

      var item_options = {
        focusTarget: 'category',
        hAxis: {
          minValue: 0,
          gridlines: {
            count: graphGridLines(data['items']['max_value'], item_desired_steps)
          }
        },
        legend: {position: 'none'},
        width: 1000, height: 350
      };
      item_options.hAxis.maxValue = graphStepSize(data['items']['max_value'], item_desired_steps) * (item_options.hAxis.gridlines.count - 1);


      drawItemChart(data['items']['data'], item_options, item_chart);
    }
  })
}

function drawItemChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'string',
    label: 'Item'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Used'
  });

  for(var key in data) {
    data_table.addRow([key, data[key]]);
  }

  chart.draw(data_table, options);
}
